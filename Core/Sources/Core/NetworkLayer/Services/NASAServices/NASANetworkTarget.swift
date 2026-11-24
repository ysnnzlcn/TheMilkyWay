//
//  NASANetworkTarget.swift
//
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

public enum NASANetworkTarget: Sendable {

    case searchImages(key: String)
}

extension NASANetworkTarget: NetworkTarget {

    public var baseURL: String {
        "https://images-api.nasa.gov/"
    }

    public var path: String {
        switch self {
        case .searchImages:
            "search"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .searchImages:
            .get
        }
    }

    public var headers: [String: String]? {
        switch self {
        case .searchImages:
            nil
        }
    }

    public var body: Data? {
        switch self {
        case .searchImages:
            nil
        }
    }

    public var queryItems: [URLQueryItem] {
        switch self {
        case .searchImages(let text):
            [.init(name: "q", value: text)]
        }
    }
}
