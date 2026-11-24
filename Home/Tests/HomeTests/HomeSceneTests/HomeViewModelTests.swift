//
//  HomeViewModelTests.swift
//
//
//  Created by Yasin Nazlican on 20.11.2021.
//

import CoreAPI
import CoreBase
import CoreUI
import Home
import XCTest

@MainActor
final class HomeViewModelTests: XCTestCase {

    private let images = (1...3).map { NASAImageDTO(id: "ID-\($0)", title: "Image \($0)") }

    private var page: ImageSearchPageDTO {
        ImageSearchPageDTO(images: images, totalHits: images.count, hasNextPage: false)
    }

    func test_getImages_shouldRequestFirstPageOfEveryImage() async {
        let api = ImageSearchApiMock(result: .success(page))
        let sut = HomeViewModel(imageSearchApi: api)

        await sut.getImages()

        let requests = await api.requests
        XCTAssertEqual(requests, [SearchImagesRequest(query: "", page: 1)])
    }

    func test_givenServiceCallSucceeds_shouldUpdateItemsAndStopLoading() async {
        let sut = HomeViewModel(imageSearchApi: ImageSearchApiMock(result: .success(page)))

        await sut.getImages()

        XCTAssertEqual(sut.items, images)
        guard case .toggleLoading(false) = sut.state else {
            return XCTFail("Expected loading to stop")
        }
    }

    func test_givenServiceCallFails_shouldUpdateStateWithError() async {
        let error = AppError.api(.server)
        let sut = HomeViewModel(imageSearchApi: ImageSearchApiMock(result: .failure(error)))

        await sut.getImages()

        XCTAssertTrue(sut.items.isEmpty)
        guard case .error(let message) = sut.state else {
            return XCTFail("Expected an error state")
        }
        XCTAssertEqual(message, error.message)
    }

    func test_itemSelected_shouldUpdateStateWithNavigation() async {
        let sut = HomeViewModel(imageSearchApi: ImageSearchApiMock(result: .success(page)))
        await sut.getImages()

        sut.itemSelected(at: 0)

        guard case .itemSelected(let item) = sut.state else {
            return XCTFail("Expected a selected item")
        }
        XCTAssertEqual(item, images[0])
    }
}
