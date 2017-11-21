//
//  Endpoint.swift
//  LogJog
//
//  Created by Ivan Dilchovski on 7.10.17.
//  Copyright © 2017 Ivan Dilchovski. All rights reserved.
//

import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String : Any]? { get }
    var encoding: NetworkRequestParameterEncoding { get }
    var headers: [String : String]? { get }
    var authenticated: Bool { get }
}

enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
}

enum NetworkRequestParameterEncoding {
    case json
    case url
}


extension Endpoint {
    internal var defaultHeaders: [String : String] {
        return [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
    }
}


struct EndpointStub: Endpoint {
    var baseURL: String
    var path: String
    var method: HTTPMethod
    var parameters: [String : Any]?
    var encoding: NetworkRequestParameterEncoding
    var headers: [String : String]?
    var authenticated: Bool
}
