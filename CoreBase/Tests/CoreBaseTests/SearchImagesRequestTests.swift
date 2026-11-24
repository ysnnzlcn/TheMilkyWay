//
//  SearchImagesRequestTests.swift
//  CoreBaseTests
//

import CoreBase
import Testing

struct SearchImagesRequestTests {

    @Test(arguments: [("  moon ", "moon"), ("\nmars\t", "mars"), ("   ", "")])
    func trimmedQueryDropsSurroundingSpaces(query: String, expected: String) {
        #expect(SearchImagesRequest(query: query).trimmedQuery == expected)
    }

    @Test func pagesStartAtOne() {
        #expect(SearchImagesRequest(query: "", page: 1).validationError == nil)

        guard case .unexpected = SearchImagesRequest(query: "", page: 0).validationError else {
            Issue.record("Expected an unexpected error")
            return
        }
    }
}
