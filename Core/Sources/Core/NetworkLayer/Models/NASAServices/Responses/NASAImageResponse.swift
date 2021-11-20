//
//  NASAImageResponse.swift
//  
//
//  Created by Yasin Nazlican on 20.11.2021.
//

import Foundation

// MARK: NASAImageResponse

public struct NASAImageResponse: Decodable {

    public let collection: NASAImageResponseCollection

    public init(collection: NASAImageResponseCollection) {
        self.collection = collection
    }
}

// MARK: NASAImageResponseCollection

public struct NASAImageResponseCollection: Decodable {

    public let items: [NASAImage]

    public init(items: [NASAImage]) {
        self.items = items
    }
}

// MARK: NASAImage

public struct NASAImage: Decodable {

    public let info: [NASAImageInfo]
    public let links: [NASAImageLink]

    public init(
        info: [NASAImageInfo],
        links: [NASAImageLink]
    ) {
        self.info = info
        self.links = links
    }

    private enum CodingKeys: String, CodingKey {

        case info = "data"
        case links
    }
}

// MARK: NASAImageInfo

public struct NASAImageInfo: Decodable {

    public let center: String
    public let title: String
    public let photographer: String?
    public let dateCreated: String
    public let description: String

    public init(
        center: String,
        title: String,
        photographer: String?,
        dateCreated: String,
        description: String
    ) {
        self.center = center
        self.title = title
        self.photographer = photographer
        self.dateCreated = dateCreated
        self.description = description
    }

    private enum CodingKeys: String, CodingKey {

        case center, title, photographer, description
        case dateCreated = "date_created"
    }
}

// MARK: NASAImageLink

public struct NASAImageLink: Decodable {

    public let href: String
    public let rel: String

    public var percentageEncodedHref: String? {
        href.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    public init(
        href: String,
        rel: String
    ) {
        self.href = href
        self.rel = rel
    }
}

// MARK: MOCK

public extension NASAImageResponse {

    static let mock: NASAImageResponse = {
        let info = NASAImageInfo(
            center: "ARC",
            title: "ARC-2002-ACD02-0056-22",
            photographer: "Tom Trower",
            dateCreated: "2002-03-20T00:00:00Z",
            description: "VSHAIP test in 7x10ft#1 W.T. (multiple model configruations) V-22 helicopter shipboard aerodynamic interaction program: L-R seated Allen Wadcox, (standind) Mark Betzina, seated in front of computer Gloria Yamauchi, in background Kurt Long."
        )

        let link = NASAImageLink(
            href: "https://images-assets.nasa.gov/image/ARC-2002-ACD02-0056-22/ARC-2002-ACD02-0056-22~thumb.jpg",
            rel: "preview"
        )

        return .init(collection: .init(items: [NASAImage(info: [info], links: [link])]))
    }()
}
