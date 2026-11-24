//
//  ImageSearchPageDTO.swift
//  CoreBase
//

import Foundation

/// One page of search results.
public struct ImageSearchPageDTO: Equatable, Sendable {

    public let images: [NASAImageDTO]
    /// Every match for the search, not only this page.
    public let totalHits: Int
    /// Whether another page can be loaded (NASA serves at most 10,000 results).
    public let hasNextPage: Bool

    public init(images: [NASAImageDTO], totalHits: Int, hasNextPage: Bool) {
        self.images = images
        self.totalHits = totalHits
        self.hasNextPage = hasNextPage
    }
}
