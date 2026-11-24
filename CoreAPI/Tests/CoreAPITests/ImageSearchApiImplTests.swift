//
//  ImageSearchApiImplTests.swift
//  CoreAPITests
//

import CoreBase
import Foundation
import Testing
@testable import CoreAPIImpl

struct ImageSearchApiImplTests {

    // MARK: Request

    @Test func searchSendsQueryAndPaging() {
        let target = NASATarget.search(SearchImagesRequest(query: "  moon ", page: 3), pageSize: 50)

        #expect(target.path == "search")
        #expect(target.queryItems == [
            URLQueryItem(name: "q", value: "moon"),
            URLQueryItem(name: "media_type", value: "image"),
            URLQueryItem(name: "page", value: "3"),
            URLQueryItem(name: "page_size", value: "50"),
        ])
    }

    @Test func emptySearchLeavesOutQuery() {
        let target = NASATarget.search(SearchImagesRequest(query: " "), pageSize: 50)

        #expect(!target.queryItems.contains { $0.name == "q" })
    }

    @Test func pageBelowOneFailsWithoutRequest() async {
        let manager = RequestableSpy()

        let result = await ImageSearchApiImpl(networkManager: manager).searchImages(.init(query: "", page: 0))

        guard case .failure(.unexpected) = result else {
            Issue.record("Expected an unexpected error")
            return
        }
        #expect(await manager.callsCount == 0)
    }

    // MARK: Mapping

    @Test func mapsFullItem() throws {
        let page = try fixture().page(for: .init(query: "moon"), pageSize: 50)
        let image = try #require(page.images.first)

        #expect(image.id == "PIA12235")
        #expect(image.title == "Nearside of the Moon")
        #expect(image.description == "Nearside of the Moon")
        #expect(image.center == "JPL")
        #expect(image.credit == "ISRO/NASA/JPL-Caltech/Brown Univ.")
        #expect(image.dateCreated == Date(timeIntervalSince1970: 1_253_815_222))
        #expect(image.keywords == ["Moon", "Chandrayaan-1"])
        #expect(image.thumbnailURL?.absoluteString.hasSuffix("PIA12235~thumb.jpg") == true)
        #expect(image.imageURL?.absoluteString.hasSuffix("PIA12235~medium.jpg") == true)
    }

    /// The fixture also has an item without `data` and a link without `href`: both are dropped, the page still loads.
    @Test func missingFieldsBecomeNilAndBrokenEntriesAreDropped() throws {
        let page = try fixture().page(for: .init(query: "moon"), pageSize: 50)
        let image = try #require(page.images.last)

        #expect(page.images.count == 2)
        #expect(image.id == "SPARSE-1")
        #expect(image.description == nil)
        #expect(image.credit == "A. Photographer")
        #expect(image.dateCreated == nil)
        #expect(image.keywords.isEmpty)
        // Only the oversized original is left, so it is used.
        #expect(image.imageURL?.absoluteString.hasSuffix("SPARSE-1~orig.jpg") == true)
    }

    @Test(arguments: [
        (1, 20_299, true),
        (199, 20_299, true),
        (200, 20_299, false), // 200 × 50 reaches NASA's 10,000 cap.
        (1, 50, false),
        (1, 51, true),
    ])
    func hasNextPage(page: Int, totalHits: Int, expected: Bool) throws {
        let json = #"{"collection":{"items":[],"metadata":{"total_hits":\#(totalHits)}}}"#

        let result = try decode(Data(json.utf8)).page(for: .init(query: "", page: page), pageSize: 50)

        #expect(result.hasNextPage == expected)
    }

    // MARK: Helpers

    private func fixture() throws -> NASASearchResponseDTO {
        try decode(Fixture.searchResponse())
    }

    private func decode(_ data: Data) throws -> NASASearchResponseDTO {
        try JSONDecoder().decode(NASASearchResponseDTO.self, from: data)
    }
}

/// Test data from `Fixtures/`.
enum Fixture {

    /// Trimmed from a real response, plus a sparse item and broken entries.
    static func searchResponse() throws -> Data {
        let url = try #require(Bundle.module.url(forResource: "search-response", withExtension: "json"))
        return try Data(contentsOf: url)
    }
}

/// Counts requests and fails every one.
private actor RequestableSpy: Requestable {

    private(set) var callsCount = 0

    func sendRequest<T: Decodable & Sendable>(type: T.Type, target: any NetworkTarget) async -> Result<T, AppError> {
        callsCount += 1
        return .failure(.network(.server))
    }
}
