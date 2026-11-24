//
//  ImageSearchApi.swift
//  CoreAPI
//

import CoreBase

public protocol ImageSearchApi: Sendable {

    /// One page of images matching the request's text.
    func searchImages(_ request: SearchImagesRequest) async -> Result<ImageSearchPageDTO, AppError>
}

/// The default before the app wires the real API: any use is a bug.
public struct ImageSearchApiUnimplemented: ImageSearchApi {

    public init() { }

    public func searchImages(_ request: SearchImagesRequest) async -> Result<ImageSearchPageDTO, AppError> {
        fatalError("Not implemented")
    }
}
