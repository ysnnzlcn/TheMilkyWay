//
//  SearchImagesRequest.swift
//  CoreBase
//

import Foundation

/// The live API and the stubs both read it through `trimmedQuery` and `validationError`, so they accept the same
/// requests.
public struct SearchImagesRequest: Equatable, Sendable {

    /// The search text. Empty searches every image.
    public let query: String
    /// Starts at 1.
    public let page: Int

    public init(query: String, page: Int = 1) {
        self.query = query
        self.page = page
    }

    /// The text that is searched, without surrounding spaces.
    public var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Why the request can't be sent, or `nil` when it can.
    public var validationError: AppError? {
        page >= 1 ? nil : .unexpected("Pages start at 1, got \(page)")
    }
}
