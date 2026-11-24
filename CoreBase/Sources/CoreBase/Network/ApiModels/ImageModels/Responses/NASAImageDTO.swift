//
//  NASAImageDTO.swift
//  CoreBase
//

import Foundation

/// One image from NASA's image library. Only `id` and `title` are always sent.
public struct NASAImageDTO: Identifiable, Hashable, Sendable {

    /// NASA's id (`nasa_id`), stable across searches.
    public let id: String
    public let title: String
    public let description: String?
    /// The NASA center that owns the image, e.g. "JPL".
    public let center: String?
    /// The photographer, or the credited creator when there is none.
    public let credit: String?
    public let dateCreated: Date?
    public let keywords: [String]
    /// Small preview for lists.
    public let thumbnailURL: URL?
    /// Large version for the details screen.
    public let imageURL: URL?

    public init(
        id: String,
        title: String,
        description: String? = nil,
        center: String? = nil,
        credit: String? = nil,
        dateCreated: Date? = nil,
        keywords: [String] = [],
        thumbnailURL: URL? = nil,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.center = center
        self.credit = credit
        self.dateCreated = dateCreated
        self.keywords = keywords
        self.thumbnailURL = thumbnailURL
        self.imageURL = imageURL
    }
}
