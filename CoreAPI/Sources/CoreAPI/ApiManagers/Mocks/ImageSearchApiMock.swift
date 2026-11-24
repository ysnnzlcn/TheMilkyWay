//
//  ImageSearchApiMock.swift
//  CoreAPI
//

import CoreBase

/// For tests: returns `result` and records every request.
public actor ImageSearchApiMock: ImageSearchApi {

    public private(set) var requests: [SearchImagesRequest] = []
    private let result: Result<ImageSearchPageDTO, AppError>

    public init(result: Result<ImageSearchPageDTO, AppError>) {
        self.result = result
    }

    public func searchImages(_ request: SearchImagesRequest) async -> Result<ImageSearchPageDTO, AppError> {
        requests.append(request)
        return result
    }
}
