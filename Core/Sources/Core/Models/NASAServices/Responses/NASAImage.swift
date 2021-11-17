//
//  NASAImage.swift
//  
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

public struct NASAImage: Decodable {

    public let info: NASAImageInfo
    public let links: [NASAImageLink]

    public init(
        info: NASAImageInfo,
        links: [NASAImageLink]
    ) {
        self.info = info
        self.links = links
    }
}

public struct NASAImageInfo: Decodable {

    public let center: String
    public let title: String
    public let photographer: String
    public let date_created: String
    public let description: String

    public init(
        center: String,
        title: String,
        photographer: String,
        date_created: String,
        description: String
    ) {
        self.center = center
        self.title = title
        self.photographer = photographer
        self.date_created = date_created
        self.description = description
    }
}

public struct NASAImageLink: Decodable {

    public let href: String
    public let rel: String

    public init(
        href: String,
        rel: String
    ) {
        self.href = href
        self.rel = rel
    }
}

public extension NASAImage {

    static let mock: NASAImage = {
        let info = NASAImageInfo(
            center: "ARC",
            title: "ARC-2002-ACD02-0056-22",
            photographer: "Tom Trower",
            date_created: "2002-03-20T00:00:00Z",
            description: "VSHAIP test in 7x10ft#1 W.T. (multiple model configruations) V-22 helicopter shipboard aerodynamic interaction program: L-R seated Allen Wadcox, (standind) Mark Betzina, seated in front of computer Gloria Yamauchi, in background Kurt Long."
        )

        let link = NASAImageLink(
            href: "https://images-assets.nasa.gov/image/ARC-2002-ACD02-0056-22/ARC-2002-ACD02-0056-22~thumb.jpg",
            rel: "preview"
        )

        return .init(info: info, links: [link])
    }()
}
