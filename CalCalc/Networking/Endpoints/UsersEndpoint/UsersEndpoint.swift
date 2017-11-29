//
//  UsersEndpoint.swift
//  LogJog
//
//  Created by Ivan Dilchovski on 11/28/17.
//  Copyright © 2017 techlight. All rights reserved.
//

import Foundation

enum UsersEndpoint: Endpoint {
    case create(User, password: String)
    case createAuthenticated(User, password: String)
    case update(User, password: String?)
    case destroy(User)
    case getCurrent
    case getAll

    var baseURL: String { return Constants.URLs.backend }

    var path : String {
        switch self {
        case .create, .getCurrent:
            return "/users"
            
        case .createAuthenticated:
            return "/users/managed"

        case .update(let user, _):
            return "/users/\(user.id)"

        case .destroy(let user):
            return "/users/\(user.id)"

        case .getAll:
            return "/users/all"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .create, .createAuthenticated:
            return .post

        case .update:
            return .put

        case .destroy:
            return .delete

        case .getCurrent, .getAll:
            return .get
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .create(let user, let password), .createAuthenticated(let user, let password):
            return [
                "user" : [
                    "firstName" : user.firstName,
                    "lastName" : user.lastName,
                    "email" : user.email,
                    "password" : password,
                    "role" : user.role.rawValue,
                    "calorieTarget" : user.calorieTarget as Any
                ]
            ] as [String : [String : Any]]

        case .update(let user, let password):
            return [
                "user" : [
                    "firstName" : user.firstName,
                    "lastName" : user.lastName,
                    "email" : user.email,
                    "password" : password as Any,
                    "role" : user.role.rawValue,
                    "calorieTarget" : user.calorieTarget as Any
                ]
            ]

        case .destroy, .getCurrent, .getAll:
            return nil
        }
    }

    var encoding: NetworkRequestParameterEncoding {
        return .json
    }
    
    var headers: [String : String]? {
        return defaultHeaders
    }
    
    var authenticated: Bool {
        switch self {
        case .create:
            return false

        case .createAuthenticated, .getCurrent, .getAll, .update, .destroy:
            return true
        }
    }
}
