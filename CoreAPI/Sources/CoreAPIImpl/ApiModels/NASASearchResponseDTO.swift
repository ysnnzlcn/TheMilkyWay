//
//  NASASearchResponseDTO.swift
//  CoreAPIImpl
//

import CoreBase
import Foundation

/// NASA's search response as sent. Mapped to `ImageSearchPageDTO`, so its shape never leaves this module.
/// Every field the API may leave out is optional. A malformed item or link, or an item without an id or title, is
/// dropped instead of failing the page.
struct NASASearchResponseDTO: Decodable, Sendable {

    let collection: Collection

    struct Collection: Decodable, Sendable {
        let items: [Item]
        let metadata: Metadata?

        private enum CodingKeys: String, CodingKey {
            case items, metadata
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            items = try container.decode([Lossy<Item>].self, forKey: .items).compactMap(\.value)
            metadata = try? container.decodeIfPresent(Metadata.self, forKey: .metadata)
        }
    }

    struct Metadata: Decodable, Sendable {
        let totalHits: Int?

        private enum CodingKeys: String, CodingKey {
            case totalHits = "total_hits"
        }
    }

    struct Item: Decodable, Sendable {
        let data: [Info]
        let links: [Link]

        private enum CodingKeys: String, CodingKey {
            case data, links
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            data = try container.decode([Info].self, forKey: .data)
            links = (try? container.decodeIfPresent([Lossy<Link>].self, forKey: .links))?.compactMap(\.value) ?? []
        }
    }

    struct Info: Decodable, Sendable {
        let nasaId: String?
        let title: String?
        let description: String?
        let center: String?
        let photographer: String?
        let secondaryCreator: String?
        let dateCreated: String?
        let keywords: [String]?

        private enum CodingKeys: String, CodingKey {
            case title, description, center, photographer, keywords
            case nasaId = "nasa_id"
            case secondaryCreator = "secondary_creator"
            case dateCreated = "date_created"
        }
    }

    struct Link: Decodable, Sendable {
        let href: String
        let rel: String?
        let render: String?
        let width: Int?
    }

    /// Decodes one array element, or `nil` when it is malformed.
    private struct Lossy<Value: Decodable & Sendable>: Decodable, Sendable {
        let value: Value?

        init(from decoder: any Decoder) throws {
            value = try? Value(from: decoder)
        }
    }
}

// MARK: Mapping

extension NASASearchResponseDTO {

    /// NASA serves at most this many results for one search; later pages fail.
    static let maxResults = 10_000
    /// The widest version used for the details screen; originals can be very large.
    static let maxImageWidth = 2_048

    func page(for request: SearchImagesRequest, pageSize: Int) -> ImageSearchPageDTO {
        let images = collection.items.compactMap(\.image)
        let totalHits = collection.metadata?.totalHits ?? images.count
        let loaded = request.page * pageSize
        return ImageSearchPageDTO(
            images: images,
            totalHits: totalHits,
            hasNextPage: loaded < min(totalHits, Self.maxResults)
        )
    }
}

private extension NASASearchResponseDTO.Item {

    var image: NASAImageDTO? {
        guard let info = data.first, let id = info.nasaId, let title = info.title else { return nil }
        let imageLinks = links.filter { $0.render == nil || $0.render == "image" }
        return NASAImageDTO(
            id: id,
            title: title,
            description: info.description.nonEmpty,
            center: info.center.nonEmpty,
            credit: info.photographer.nonEmpty ?? info.secondaryCreator.nonEmpty,
            dateCreated: info.dateCreated.flatMap { try? Date($0, strategy: .iso8601) },
            keywords: info.keywords ?? [],
            thumbnailURL: Self.thumbnailURL(in: imageLinks),
            imageURL: Self.imageURL(in: imageLinks)
        )
    }

    static func thumbnailURL(in links: [NASASearchResponseDTO.Link]) -> URL? {
        let preview = links.first { $0.rel == "preview" } ?? links.first
        return preview.flatMap { URL(string: $0.href) }
    }

    /// The widest version up to `maxImageWidth`, else the original, else the preview.
    static func imageURL(in links: [NASASearchResponseDTO.Link]) -> URL? {
        let sized = links
            .filter { ($0.width ?? .max) <= NASASearchResponseDTO.maxImageWidth }
            .max { ($0.width ?? 0) < ($1.width ?? 0) }
        let link = sized ?? links.first { $0.rel == "canonical" } ?? links.first
        return link.flatMap { URL(string: $0.href) }
    }
}

private extension String? {

    /// `nil` for a missing or blank value.
    var nonEmpty: String? {
        guard let text = self?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
        return text
    }
}
