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
        case .serverError(let errors): errorMessage = errors.flatMap({ $0.message }).joined(separator: ". ")
        case .cancelled: errorMessage = "Cancelled"

        case .noConnection: errorMessage = "Connection to server failed"
        }

        return errorMessage ?? "Server error"
    }

    var isFailedAuthentication: Bool {
        let authenticationErrors: [ServerError.ErrorCode] = [.authenticationFailed, .tokenInvalid, .tokenExpired]
        if case .serverError(let errors) = self,
            errors.filter({ authenticationErrors.contains($0.code) }).count > 0 {

            return true
        } else { return false }
    }

    func isServerError(_ code: ServerError.ErrorCode) -> Bool {
        if case .serverError(let errors) = self {
            return errors.contains(where: { $0.code == code })
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
    enum ErrorCode: String, Decodable {
        case unknown
        
        case wrongArguments = "GEN-WRONG-ARGS"
        case noResult = "GEN-NOT-FOUND"
        
        case authenticationFailed
        case tokenInvalid
        case tokenExpired
    }
    enum RootCodingKeys: String, CodingKey {
        case error
    }
    
    enum ErrorCodingKeys: String, CodingKey {
        case code
        case httpCode = "http_code"
        case message
    }
    
    var code: ErrorCode = .unknown
    var message: String? = nil
    var httpCode: Int
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let container = try rootContainer.nestedContainer(keyedBy: ErrorCodingKeys.self, forKey: .error)
        
        self.code = try container.decode(ErrorCode.self, forKey: .code)
        self.httpCode = try container.decode(Int.self, forKey: .httpCode)
        self.message = try container.decode(String.self, forKey: .message)
    }
}

extension ServerError: Equatable {}
func == (lhs: ServerError, rhs: ServerError) -> Bool {
    return lhs.code == rhs.code
}
