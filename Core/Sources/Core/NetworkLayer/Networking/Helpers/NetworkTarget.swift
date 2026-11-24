//
//  NetworkTarget.swift
//
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

public protocol NetworkTarget: Sendable {

    /// The server address, ending in `/`.
    var baseURL: String { get }

    /// The path appended to `baseURL`.
    var path: String { get }

    /// Overrides the default timeout.
    var requestTimeout: TimeInterval? { get }

    /// The HTTP method used in the request.
    var method: HTTPMethod { get }

    /// The headers to be used in the request.
    var headers: [String: String]? { get }

    /// The body to be used in the target.
    var body: Data? { get }

    /// Query items to be used in request.
    var queryItems: [URLQueryItem] { get }
}

extension NetworkTarget {

    public var requestTimeout: TimeInterval? { nil }
}
