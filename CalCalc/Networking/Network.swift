//
//  Network.swift
//  LogJog
//
//  Created by Ivan Dilchovski on 7.10.17.
//  Copyright © 2017 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Result

protocol Network {
    func request(endpoint: Endpoint,
                 handler: ((Result<HTTPURLResponse, RequestError>) -> ())?) -> NetworkRequest

    func apiRequest(endpoint: Endpoint,
                    handler: ((Result<Data, RequestError>) -> ())?) -> NetworkRequest
}

class DefaultNetwork: Network {
    fileprivate var authHeader: [String : String]?
    fileprivate var tokenChangedObserver: NSObjectProtocol?

    fileprivate let lock = NSLock()
    fileprivate var isUpdatingToken: Bool = false
    fileprivate var enqueuedRequests: [(Endpoint, handler: ((Result<Data, RequestError>) -> ())?)] = []

    fileprivate let provider: NetworkProvider
    fileprivate let notificationCenter: NotificationCenter

    static let shared = DefaultNetwork()

    init(provider: NetworkProvider = URLSessionNetworkProvider(),
         notificationCenter: NotificationCenter = NotificationCenter.default,
         authHeader: [String : String]? = nil ) {
        self.provider = provider
        self.notificationCenter = notificationCenter
        self.authHeader = authHeader

        // Handle auth token updates
        tokenChangedObserver = notificationCenter.addObserver(forType: Notifications.Networking.AuthTokenUpdated.self, observingObject: nil, queue: nil) { [weak self] notification in
            guard let wself = self else { return }
            wself.lock.lock()

            if let accessToken = notification.accessToken {
                wself.authHeader = ["Authorization" : "Bearer \(accessToken)"]
            } else {
                wself.authHeader = nil
            }

            let enqueuedRequests = wself.enqueuedRequests
            wself.enqueuedRequests.removeAll()
            wself.isUpdatingToken = false

            wself.lock.unlock()

            for (endpoint, handler) in enqueuedRequests {
                netLog.info("Calling backlogged \(endpoint.method.rawValue.uppercased()) \(endpoint.path)")
                _ = wself.apiRequest(endpoint: endpoint, handler: handler)
            }
        }
    }

    deinit {
        if let tokenChangedObserver = tokenChangedObserver {
            notificationCenter.removeObserver(tokenChangedObserver)
        }
    }

    func request(endpoint: Endpoint,
                 handler: ((Result<HTTPURLResponse, RequestError>) -> ())?) -> NetworkRequest {

        return provider.request(endpoint: endpoint, responseHandler: { result in
            switch result {
            case .failure(let error):
                let requestError = self.handle(error: error, forPath: "\(endpoint.method.rawValue.uppercased()) \(endpoint.path)")
                handler?(Result.failure(requestError))

            case .success(let urlResponse):
                if urlResponse.statusCode >= 200 && urlResponse.statusCode <= 299 { //Only possible way for success
                    netLog.error("\(endpoint.method.rawValue.uppercased()) \(endpoint.path) success")
                    handler?(Result.success(urlResponse))
                } else {
                    netLog.error("\(endpoint.method.rawValue.uppercased()) \(endpoint.path) failed. Status code != 2XX")
                    let requestError = RequestError.statusCode(statusCode: urlResponse.statusCode, message: "Status code \(urlResponse.statusCode)")
                    handler?(Result.failure(requestError))
                }
            }
        })
    }

    /// Request that expects the response to be in the custom backend format
    /// Success result is JSON data
    func apiRequest(endpoint: Endpoint,
                    handler: ((Result<Data, RequestError>) -> ())?) -> NetworkRequest {

        var endpoint = endpoint

        if endpoint.authenticated, let authorization = authHeader?["Authorization"] {
            endpoint = EndpointStub(baseURL: endpoint.baseURL,
                                    path: endpoint.path,
                                    method: endpoint.method,
                                    parameters: endpoint.parameters,
                                    encoding: endpoint.encoding,
                                    headers: (endpoint.headers ?? [:]).merging(["Authorization" : authorization], uniquingKeysWith: { old, new in return  new }),
                                    authenticated: endpoint.authenticated)
        }

        return provider.request(endpoint: endpoint, dataHandler: { result in
            switch result {
            case .failure(let error):
                let requestError = self.handle(error: error, forPath: "\(endpoint.method.rawValue.uppercased()) \(endpoint.path)")
                handler?(.failure(requestError))

            case .success((let response, let data)):
                guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any] else {
                    netLog.error("\(endpoint.method.rawValue.uppercased()) \(endpoint.path) failed. could not parse JSON from response")
                    handler?(.failure(.badResponse(message: "Could not process JSON from server response")))
                    return
                }
                
                let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    print(string)
                }
                
                let jsonDecoder = JSONDecoder()
                if response.statusCode >= 200 && response.statusCode <= 299 {
                    if let payload = json["data"] as? [String : Any], let payloadData = try? JSONSerialization.data(withJSONObject: payload, options: []) {
                        netLog.info("\(endpoint.method.rawValue.uppercased()) \(endpoint.path) success")
                        handler?(.success(payloadData)) /* Only possible success */
                    } else {
                        netLog.error("\(endpoint.method.rawValue.uppercased()) \(endpoint.path) failed. Status code \(response.statusCode), but no 'data' field in json")
                        handler?(.failure(.badResponse(message: "No 'data' field in json with status code \(response.statusCode)")))
                    }
                } else if json["error"] != nil, let error = try? jsonDecoder.decode(ServerError.self, from: data)  {
                    netLog.error("\(endpoint.method.rawValue.uppercased()) \(endpoint.path) failed. Server error: \(error.code.rawValue)")
                    
                    // Handle expired auth token by backlogging requests and signaling for re-login
                    if error.code == .tokenExpired || error.code == .tokenInvalid {
                        if !self.isUpdatingToken {
                            netLog.info("Token expired. Requesting new.")
                            
                            var headers = (endpoint.headers ?? [:])
                            headers["Authorization"] = nil
                            endpoint = EndpointStub(baseURL: endpoint.baseURL,
                                                    path: endpoint.path,
                                                    method: endpoint.method,
                                                    parameters: endpoint.parameters,
                                                    encoding: endpoint.encoding,
                                                    headers: headers,
                                                    authenticated: endpoint.authenticated)
                            
                            self.lock.lock();
                            self.isUpdatingToken = true
                            self.enqueuedRequests.append((endpoint, handler))
                            self.lock.unlock()
                            
                            self.notificationCenter.postTypedNotification(Notifications.AccountManager.AutoLoginRequest(tokenExpired: true))
                        } else {
                            self.lock.lock();
                            netLog.info("Token expired. Enqueueing.")
                            self.enqueuedRequests.append((endpoint, handler))
                            self.lock.unlock();
                        }
                    } else {
                        handler?(.failure(.serverError(errors: [error])))
                    }
                } else {
                    netLog.error("\(endpoint.method.rawValue.uppercased()) \(endpoint.path) failed. Bad status code \(response.statusCode)")
                    handler?(.failure(.statusCode(statusCode: response.statusCode, message: nil)))
                }
            }
        })
    }
}

// **********
// MARK: - Parse JSON for errors
// **********

extension DefaultNetwork
{
    fileprivate func handle(error: NetworkProviderError, forPath path: String) -> RequestError {
        switch error {
        case .error(let error):
            netLog.error("\(path) failed. Error sending request to server: \(error.localizedDescription)")
            return .requestFailure(message: error.localizedDescription)

        case .noConnection:
            netLog.error("\(path) failed. No network connection.")
            return .noConnection

        case .badResponse:
            netLog.error("\(path) failed. Could not process server response.")
            return .badResponse(message: "Could not process server response")
        }
    }
}
