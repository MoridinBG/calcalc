//
//  URLSessionNetworkProvider.swift
//  LogJog
//
//  Created by Ivan Dilchovski on 7.10.17.
//  Copyright © 2017 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Result

extension URLSessionTask: NetworkRequest {}

class URLSessionNetworkProvider: NetworkProvider {
    fileprivate let session: URLSession

    init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }

    func request(endpoint: Endpoint, dataHandler: @escaping (_ result: Result<(HTTPURLResponse, Data), NetworkProviderError>) -> ()) -> NetworkRequest {
        let task = session.dataTask(with: endpoint.request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, let response = response as? HTTPURLResponse else {
                    if let error = error as NSError? {
                        if error.domain == NSURLErrorDomain && error.code == -999 {
                            // Do nothing - task is cancelled
                        } else if error.domain == NSURLErrorDomain && error.code < -1001 && error.code > -1011  {
                            dataHandler(.failure(.noConnection))
                        } else {
                            dataHandler(.failure(.error(error)))
                        }
                    } else {
                        dataHandler(Result.failure(.badResponse))
                    }
                    return
                }

                dataHandler(Result.success((response, data)))
            }
        }

        task.resume()
        return task
    }

    func request(endpoint: Endpoint, responseHandler: @escaping (_ result: Result<HTTPURLResponse, NetworkProviderError>) -> ()) -> NetworkRequest {
        let task = session.dataTask(with: endpoint.request) { _, response, error in
            DispatchQueue.main.async {
                guard let response = response as? HTTPURLResponse else {
                    if let error = error as NSError? {
                        if error.domain == NSURLErrorDomain && error.code < -1001 && error.code > -1011  {
                            responseHandler(.failure(.noConnection))
                        } else {
                            responseHandler(.failure(.error(error)))
                        }
                    } else {
                        responseHandler(.failure(.badResponse))
                    }
                    return
                }

                responseHandler(.success(response))
            }
        }
        task.resume()

        return task
    }
}
