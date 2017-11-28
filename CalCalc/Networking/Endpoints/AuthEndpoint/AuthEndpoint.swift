//
//  AuthEndpoint.swift
//  LogJog
//
//  Created by Ivan Dilchovski on 11/28/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation

enum AuthEndpoint: Endpoint {
    case login(email: String, password: String)

    var baseURL: String { return Constants.URLs.backend }

    var path : String {
        switch self {
        case .login:
            return "/auth/login"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .login:
            return nil
        }
    }

    var encoding: NetworkRequestParameterEncoding {
        return .json
    }

    var headers: [String : String]? {
        switch self {
        case .login(let email, let password):
            if let base64Encoded = "\(email):\(password)".base64Encoded() {
                return defaultHeaders.merging(["Authorization" : "Basic \(base64Encoded)"], uniquingKeysWith: { $1 })
            } else {
                netLog.error("Could not base64 encode credentials string")
            }
        }

        return defaultHeaders
    }

    var authenticated: Bool {
        return false
    }
}
