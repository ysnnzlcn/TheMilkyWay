//
//  SearchImagesRequest.swift
//  CoreBase
//

import Foundation

public struct SearchImagesRequest: Equatable, Sendable {

    /// The search text. Empty searches every image.
    public let query: String
    /// Starts at 1.
    public let page: Int

    public init(query: String, page: Int = 1) {
        self.query = query
        self.page = page
    }
}
