//
//  NASATarget.swift
//  CoreAPIImpl
//

import CoreBase
import Foundation

/// NASA Image and Video Library (`images-api.nasa.gov`): public, no API key.
enum NASATarget: NetworkTarget {

    case search(SearchImagesRequest, pageSize: Int)

    var baseURL: String { "https://images-api.nasa.gov/" }

    var path: String {
        switch self {
        case .search: "search"
        }
    }

    var method: HTTPMethod { .get }

    var headers: [String: String]? { nil }

    var body: Data? { nil }

    var queryItems: [URLQueryItem] {
        switch self {
        case .search(let request, let pageSize):
            let query = request.query.trimmingCharacters(in: .whitespacesAndNewlines)
            // Without `q` NASA searches every image.
            let searchItems = query.isEmpty ? [] : [URLQueryItem(name: "q", value: query)]
            return searchItems + [
                URLQueryItem(name: "media_type", value: "image"),
                URLQueryItem(name: "page", value: String(request.page)),
                URLQueryItem(name: "page_size", value: String(pageSize)),
            ]
        }
    }
}
