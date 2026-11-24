//
//  ImageSearchApiMock.swift
//  CoreAPIMocks
//

import CoreAPI
import CoreBase

/// For tests: answers every request with `handler` and records the requests.
public actor ImageSearchApiMock: ImageSearchApi {

    public typealias Handler = @Sendable (SearchImagesRequest) -> Result<ImageSearchPageDTO, AppError>

    public private(set) var requests: [SearchImagesRequest] = []
    private let handler: Handler

    /// Every request gets `result`.
    public init(result: Result<ImageSearchPageDTO, AppError>) {
        self.handler = { _ in result }
    }

    /// Each request gets its own answer, e.g. by page.
    public init(handler: @escaping Handler) {
        self.handler = handler
    }

    public func searchImages(_ request: SearchImagesRequest) async -> Result<ImageSearchPageDTO, AppError> {
        requests.append(request)
        return handler(request)
    }
}
