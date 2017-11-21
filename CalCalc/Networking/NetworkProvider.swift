//
//  NetworkProvider.swift
//  LogJog
//
//  Created by Ivan Dilchovski on 7.10.17.
//  Copyright © 2017 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Result

protocol NetworkProvider {
    func request(endpoint: Endpoint, dataHandler: @escaping (_ result: Result<(HTTPURLResponse, Data), NetworkProviderError>) -> ()) -> NetworkRequest
    func request(endpoint: Endpoint, responseHandler: @escaping (_ result: Result<HTTPURLResponse, NetworkProviderError>) -> ()) -> NetworkRequest
}

enum NetworkProviderError: Error {
    case badResponse
    case noConnection
    case error(Error)
}

protocol NetworkRequest {
    func resume()
    func suspend()
    func cancel()
}
