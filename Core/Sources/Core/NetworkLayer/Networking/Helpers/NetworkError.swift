//
//  NetworkError.swift
//  
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

public enum NetworkError: Error, Equatable {
    
    case badURL(_ error: String)
    case apiError(code: Int, error: String)
    case invalidJSON(_ error: String)
    case unauthorized(code: Int, error: String)
    case badRequest(code: Int, error: String)
    case serverError(code: Int, error: String)
    case noResponse(_ error: String)
    case unableToParseData(_ error: String)
    case unknown(code: Int, error: String)
}
