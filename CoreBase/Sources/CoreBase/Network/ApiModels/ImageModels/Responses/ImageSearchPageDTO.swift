//
//  ImageSearchPageDTO.swift
//  CoreBase
//

import Foundation

/// One page of search results.
public struct ImageSearchPageDTO: Equatable, Sendable {

    public let images: [NASAImageDTO]
    /// Whether another page can be loaded (NASA serves at most 10,000 results).
    public let hasNextPage: Bool

    public init(images: [NASAImageDTO], hasNextPage: Bool) {
        self.images = images
        self.hasNextPage = hasNextPage
    }
}
