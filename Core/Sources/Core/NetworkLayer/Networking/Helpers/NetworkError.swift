//
//  NetworkError.swift
//  
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

public struct NetworkErrorResponse: Decodable {

    public let reason: String
}

public enum NetworkError: Error {
    
    case error(Error)
    case internalError(NetworkErrorResponse)

    public var customDescription: String {
        switch self {
        case .error(let error):
            return error.localizedDescription

        case .internalError(let response):
            return response.reason
        }
    }
}
