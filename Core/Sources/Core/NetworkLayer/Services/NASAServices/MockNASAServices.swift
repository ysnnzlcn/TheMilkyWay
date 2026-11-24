//
//  MockNASAServices.swift
//
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

public actor MockNASAServices: NASAServices {

    // MARK: Public Variables

    public private(set) var searchImagesCallsCount = 0

    // MARK: Private Variables

    private let searchImagesResult: Result<NASAImageResponse, AppError>

    // MARK: Life-Cycle

    public init(searchImagesResult: Result<NASAImageResponse, AppError> = .success(.mock)) {
        self.searchImagesResult = searchImagesResult
    }

    // MARK: Protocol Conformance

    public func searchImages() async -> Result<NASAImageResponse, AppError> {
        searchImagesCallsCount += 1
        return searchImagesResult
    }
}
