//
//  NASAImageDTO+Stubs.swift
//  CoreAPIStubs
//

import CoreBase
import Foundation

public extension NASAImageDTO {

    /// Offline sample data. The image addresses point at real NASA images, so previews still show pictures.
    static let stubs: [NASAImageDTO] = (1...45).map { index in
        let sample = samples[index % samples.count]
        return NASAImageDTO(
            id: "STUB-\(index)",
            title: "\(sample.title) \(index)",
            description: sample.description,
            center: sample.center,
            credit: sample.credit,
            dateCreated: Date(timeIntervalSince1970: 1_253_815_222 + Double(index) * 86_400),
            keywords: sample.keywords,
            thumbnailURL: URL(string: "https://images-assets.nasa.gov/image/\(sample.id)/\(sample.id)~thumb.jpg"),
            imageURL: URL(string: "https://images-assets.nasa.gov/image/\(sample.id)/\(sample.id)~small.jpg")
        )
    }
}

private struct Sample {
    let id: String
    let title: String
    let description: String
    let center: String
    let credit: String
    let keywords: [String]
}

private let samples = [
    Sample(
        id: "PIA12235",
        title: "Nearside of the Moon",
        description: "The side of the Moon that always faces Earth.",
        center: "JPL",
        credit: "ISRO/NASA/JPL-Caltech/Brown Univ.",
        keywords: ["Moon", "Chandrayaan-1"]
    ),
    Sample(
        id: "PIA13517",
        title: "Color of the Moon",
        description: "The Moon's surface in enhanced color.",
        center: "JPL",
        credit: "NASA/GSFC/Arizona State University",
        keywords: ["Moon", "Lunar Reconnaissance Orbiter LRO"]
    ),
]
