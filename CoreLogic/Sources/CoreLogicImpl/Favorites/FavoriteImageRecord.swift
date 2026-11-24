//
//  FavoriteImageRecord.swift
//  CoreLogicImpl
//

import CoreBase
import Foundation
import SwiftData

/// A saved image as SwiftData stores it. Never leaves this module: the service maps it to `NASAImageDTO`.
@Model
final class FavoriteImageRecord {

    @Attribute(.unique) var id: String
    var title: String
    var imageDescription: String?
    var center: String?
    var credit: String?
    var dateCreated: Date?
    var keywords: [String]
    var thumbnailURL: URL?
    var imageURL: URL?
    /// Newest first in the list.
    var savedAt: Date

    init(image: NASAImageDTO, savedAt: Date) {
        id = image.id
        title = image.title
        imageDescription = image.description
        center = image.center
        credit = image.credit
        dateCreated = image.dateCreated
        keywords = image.keywords
        thumbnailURL = image.thumbnailURL
        imageURL = image.imageURL
        self.savedAt = savedAt
    }

    var image: NASAImageDTO {
        NASAImageDTO(
            id: id,
            title: title,
            description: imageDescription,
            center: center,
            credit: credit,
            dateCreated: dateCreated,
            keywords: keywords,
            thumbnailURL: thumbnailURL,
            imageURL: imageURL
        )
    }
}
