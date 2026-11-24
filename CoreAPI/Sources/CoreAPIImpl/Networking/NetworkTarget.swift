//
//  NetworkTarget.swift
//  CoreAPIImpl
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

protocol NetworkTarget: Sendable {

    /// The server address, ending in `/`.
    var baseURL: String { get }

    /// The path appended to `baseURL`.
    var path: String { get }

    /// Overrides the default timeout.
    var requestTimeout: TimeInterval? { get }

    var method: HTTPMethod { get }

    var queryItems: [URLQueryItem] { get }
}

extension NetworkTarget {

    var requestTimeout: TimeInterval? { nil }
}
