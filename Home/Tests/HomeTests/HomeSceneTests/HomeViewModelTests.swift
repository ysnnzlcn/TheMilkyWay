//
//  HomeViewModelTests.swift
//
//
//  Created by Yasin Nazlican on 20.11.2021.
//

import Core
import CoreUI
import Home
import XCTest

@MainActor
final class HomeViewModelTests: XCTestCase {

    func test_getImages_shouldCallService() async {
        let service = MockNASAServices()
        let sut = HomeViewModel(service: service)

        await sut.getImages()

        let callsCount = await service.searchImagesCallsCount
        XCTAssertEqual(callsCount, 1)
    }

    func test_givenServiceCallSucceeds_shouldUpdateItemsAndStopLoading() async {
        let sut = HomeViewModel(service: MockNASAServices())

        await sut.getImages()

        XCTAssertEqual(sut.items, NASAImageResponse.mock.collection.items)
        guard case .toggleLoading(false) = sut.state else {
            return XCTFail("Expected loading to stop")
        }
    }

    func test_givenServiceCallFails_shouldUpdateStateWithError() async {
        let error = AppError.api(.server)
        let sut = HomeViewModel(service: MockNASAServices(searchImagesResult: .failure(error)))

        await sut.getImages()

        XCTAssertTrue(sut.items.isEmpty)
        guard case .error(let message) = sut.state else {
            return XCTFail("Expected an error state")
        }
        XCTAssertEqual(message, error.message)
    }

    func test_itemSelected_shouldUpdateStateWithNavigation() async {
        let sut = HomeViewModel(service: MockNASAServices())
        await sut.getImages()

        sut.itemSelected(at: 0)

        guard case .itemSelected(let item) = sut.state else {
            return XCTFail("Expected a selected item")
        }
        XCTAssertEqual(item, NASAImageResponse.mock.collection.items[0])
    }
}
