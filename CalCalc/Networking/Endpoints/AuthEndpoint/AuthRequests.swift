//
//  AuthRequests.swift
//  LogJog
//
//  Created by Ivan Dilchovski on 11/28/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation
import Result

protocol AuthRequests {
    @discardableResult
    func login(email: String, password: String, handler: ((Result<String, RequestError>) -> ())?) -> NetworkRequest
}

struct DefaultAuthRequests: AuthRequests {
    fileprivate let network: Network

    init(network: Network = DefaultNetwork.shared) {
        self.network = network
    }

    func login(email: String, password: String, handler: ((Result<String, RequestError>) -> ())?) -> NetworkRequest {
        return network.apiRequest(endpoint: AuthEndpoint.login(email: email, password: password)) { result in
            handler?(result.flatMap({ data in
                guard let token = try? JSONDecoder().decode(AuthToken.self, from: data) else {
                    netLog.error("Could not parse access token from response")
                    return .failure(RequestError.badResponse(message: "Could not parse access token from response"))
                }
                return .success(token.accessToken)
            }))
        }
    }
}
