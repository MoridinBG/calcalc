//
//  UsersRequests.swift
//  LogJog
//
//  Created by Ivan Dilchovski on 11/28/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation
import Result

protocol UsersRequests {
    @discardableResult
    func register(user: User, withPassword password: String, handler: ((Result<User, RequestError>) -> ())?) -> NetworkRequest
    
    @discardableResult
    func registerAuthenticated(user: User, withPassword password: String, handler: ((Result<User, RequestError>) -> ())?) -> NetworkRequest

    @discardableResult
    func update(user: User, withPassword password: String?, handler: ((Result<User, RequestError>) -> ())?) -> NetworkRequest

    @discardableResult
    func delete(user: User, handler: ((Result<Void, RequestError>) -> ())?) -> NetworkRequest

    @discardableResult
    func getCurrent(handler: ((Result<User, RequestError>) -> ())?) -> NetworkRequest

    @discardableResult
    func getAll(handler: ((Result<[User], RequestError>) -> ())?) -> NetworkRequest
}

struct DefaultUsersRequests: UsersRequests {
    private let network: Network

    init(network: Network = DefaultNetwork.shared) {
        self.network = network
    }

    func register(user: User, withPassword password: String, handler: ((Result<User, RequestError>) -> ())?) -> NetworkRequest {
        return network.apiRequest(endpoint: UsersEndpoint.create(user, password: password)) { result in
            handler?(result.flatMap({ data in
                guard let user = (try? JSONDecoder().decode([String : User].self, from: data))?["user"] else {
                    netLog.error("Could not parse user from response")
                    return .failure(RequestError.badResponse(message: "Could not parse user from response"))
                }
                return .success(user)
            }))
        }
    }
    
    func registerAuthenticated(user: User, withPassword password: String, handler: ((Result<User, RequestError>) -> ())?) -> NetworkRequest {
        return network.apiRequest(endpoint: UsersEndpoint.createAuthenticated(user, password: password)) { result in
            handler?(result.flatMap({ data in
                guard let user = (try? JSONDecoder().decode([String : User].self, from: data))?["user"] else {
                    netLog.error("Could not parse user from response")
                    return .failure(RequestError.badResponse(message: "Could not parse user from response"))
                }
                return .success(user)
            }))
        }
    }

    func update(user: User, withPassword password: String?, handler: ((Result<User, RequestError>) -> ())?) -> NetworkRequest {
        return network.apiRequest(endpoint: UsersEndpoint.update(user, password: password)) { result in
            handler?(result.flatMap({ data in
                guard let user = (try? JSONDecoder().decode([String : User].self, from: data))?["user"] else {
                    netLog.error("Could not parse user from response")
                    return .failure(RequestError.badResponse(message: "Could not parse user from response"))
                }
                return .success(user)
            }))
        }
    }

    func delete(user: User, handler: ((Result<Void, RequestError>) -> ())?) -> NetworkRequest {
        return network.apiRequest(endpoint: UsersEndpoint.destroy(user)) { result in
            handler?(result.map { _ -> Void in return () })
        }
    }

    func getCurrent(handler: ((Result<User, RequestError>) -> ())?) -> NetworkRequest {
        return network.apiRequest(endpoint: UsersEndpoint.getCurrent) { result in
            handler?(result.flatMap({ data in
                guard let user = (try? JSONDecoder().decode([String : User].self, from: data))?["user"] else {
                    netLog.error("Could not parse user from response")
                    return .failure(RequestError.badResponse(message: "Could not parse user from response"))
                }
                return .success(user)
            }))
        }
    }

    func getAll(handler: ((Result<[User], RequestError>) -> ())?) -> NetworkRequest {
        return network.apiRequest(endpoint: UsersEndpoint.getAll) { result in
            handler?(result.flatMap({ data in
                guard let users = (try? JSONDecoder().decode([String : [User]].self, from: data))?["users"] else {
                    netLog.error("Could not parse users from response")
                    return .failure(RequestError.badResponse(message: "Could not parse users from response"))
                }

                return .success(users)
            }))
        }
    }
}
