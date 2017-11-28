//
//  RequestError.swift
//  LogJog
//
//  Created by Ivan Dilchovski on 7.10.17.
//  Copyright © 2017 Ivan Dilchovski. All rights reserved.
//

import Foundation

enum RequestError: Error {
    case statusCode(statusCode: Int, message: String?)
    case requestFailure(message: String?)
    case badResponse(message: String?)
    case serverError(errors: [ServerError])
    case cancelled

    case noConnection

    var errorMessage: String {
        var errorMessage: String?

        switch self {

        case .statusCode(_, let message): errorMessage = message
        case .requestFailure(let message): errorMessage = message
        case .badResponse(let message): errorMessage = message
        case .serverError(let errors): errorMessage = errors.flatMap({ $0.reason }).joined(separator: ". ")
        case .cancelled: errorMessage = "Cancelled"

        case .noConnection: errorMessage = "Connection to server failed"
        }

        return errorMessage ?? "Server error"
    }

    var isFailedAuthentication: Bool {
        let authenticationErrors: [ServerError.Identifier] = [.invalidCredentials, .tokenInvalid, .tokenExpired]
        if case .serverError(let errors) = self,
            errors.filter({ authenticationErrors.contains($0.identifier) }).count > 0 {

            return true
        } else { return false }
    }

    func isServerError(_ identifier: ServerError.Identifier) -> Bool {
        if case .serverError(let errors) = self {
            return errors.contains(where: { $0.identifier == identifier })
        }

        return false
    }
}


extension RequestError: Equatable {}
func == (lhs: RequestError, rhs: RequestError) -> Bool {
    switch (lhs, rhs) {
    case (.statusCode(let lhsCode, _), .statusCode(let rhsCode, _)):
        return lhsCode == rhsCode

    case (.serverError(let lhsErrors), .serverError(let rhsErrors)):
        return lhsErrors.count == rhsErrors.count && lhsErrors.filter({ !rhsErrors.contains($0) }).count == 0


    case (.requestFailure, .requestFailure),
         (.badResponse, .badResponse),
         (.cancelled, .cancelled),
         (.noConnection, .noConnection):
        return true
        
    default:
        return false
    }
}


struct ServerError: Decodable {
    enum Identifier: String, Decodable {
        case unknown
        
        case invalidCredentials = "Authentication.AuthenticationError.invalidCredentials"
        case tokenInvalid
        case tokenExpired
    }
    
    var identifier: Identifier = .unknown
    var debugReason: String
    var reason: String
}

extension ServerError: Equatable {}
func == (lhs: ServerError, rhs: ServerError) -> Bool {
    return lhs.identifier == rhs.identifier
}
