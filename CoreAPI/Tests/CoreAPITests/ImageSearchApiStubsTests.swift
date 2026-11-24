//
//  ImageSearchApiStubsTests.swift
//  CoreAPITests
//

import CoreBase
import Testing
@testable import CoreAPIStubs

struct ImageSearchApiStubsTests {

    private let api = ImageSearchApiStubs(delay: .zero)

    @Test func pagesThroughEveryStub() async throws {
        let first = try await api.searchImages(.init(query: "", page: 1)).get()
        let last = try await api.searchImages(.init(query: "", page: 3)).get()

        #expect(first.images.count == ImageSearchApiStubs.pageSize)
        #expect(first.hasNextPage)
        #expect(last.images.count == NASAImageDTO.stubs.count - 2 * ImageSearchApiStubs.pageSize)
        #expect(!last.hasNextPage)
    }

    @Test func filtersByTitleAndKeyword() async throws {
        let byTitle = try await api.searchImages(.init(query: "nearside")).get()
        let byKeyword = try await api.searchImages(.init(query: "chandrayaan")).get()
        let none = try await api.searchImages(.init(query: "mars")).get()

        #expect(!byTitle.images.isEmpty)
        #expect(byTitle.images == byKeyword.images)
        #expect(none.images.isEmpty)
        #expect(!none.hasNextPage)
    }
}
