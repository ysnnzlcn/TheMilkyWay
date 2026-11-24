//
//  ImageDetailsViewModelTests.swift
//
//
//  Created by Yasin Nazlican on 21.11.2021.
//

import Core
import Home
import XCTest

@MainActor
final class ImageDetailsViewModelTests: XCTestCase {

    func test_whenDidLoad_thenCheckForStateAndDataSource() throws {
        let selectedImage = try XCTUnwrap(NASAImageResponse.mock.collection.items.first)
        let sut = ImageDetailsViewModel(service: MockNASAServices(), imageModel: selectedImage)

        sut.didLoad()

        XCTAssertEqual(sut.imageTitle, selectedImage.info.first?.title)
        XCTAssertEqual(sut.items.count, 3)
        XCTAssertEqual(sut.items[0].cell, .imageHeaderCell(selectedImage.links.first?.percentageEncodedHref))
        guard case .plainTextCell = sut.items[1].cell, case .plainTextCell = sut.items[2].cell else {
            return XCTFail("Expected text cells")
        }
    }
}
