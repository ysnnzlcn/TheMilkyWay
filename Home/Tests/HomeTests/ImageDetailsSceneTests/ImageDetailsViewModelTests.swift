//
//  ImageDetailsViewModelTests.swift
//
//
//  Created by Yasin Nazlican on 21.11.2021.
//

import CoreBase
import Foundation
import Home
import XCTest

@MainActor
final class ImageDetailsViewModelTests: XCTestCase {

    func test_whenDidLoad_thenCheckForStateAndDataSource() {
        let image = NASAImageDTO(
            id: "ID-1",
            title: "Image 1",
            imageURL: URL(string: "https://images-assets.nasa.gov/image/ID-1/ID-1~medium.jpg")
        )
        let sut = ImageDetailsViewModel(imageModel: image)

        sut.didLoad()

        XCTAssertEqual(sut.imageTitle, image.title)
        XCTAssertEqual(sut.items.count, 3)
        XCTAssertEqual(sut.items[0].cell, .imageHeaderCell(image.imageURL?.absoluteString))
        guard case .plainTextCell = sut.items[1].cell, case .plainTextCell = sut.items[2].cell else {
            return XCTFail("Expected text cells")
        }
    }
}
