//
//  ImageSearchApiStubs.swift
//  CoreAPIStubs
//

import CoreAPI
import CoreBase
import Foundation

/// Searches `NASAImageDTO.stubs` by title and keywords, in pages, after a short delay. Used when the app runs
/// offline (`AppInterface.apiEnvironment`); it accepts the same requests as the live API.
actor ImageSearchApiStubs: ImageSearchApi {

    static let pageSize = 20

    private let delay: Duration

    init(delay: Duration = .milliseconds(300)) {
        self.delay = delay
    }

    func searchImages(_ request: SearchImagesRequest) async -> Result<ImageSearchPageDTO, AppError> {
        try? await Task.sleep(for: delay)
        if let error = request.validationError { return .failure(error) }

        let query = request.trimmedQuery
        let matches = NASAImageDTO.stubs.filter { image in
            query.isEmpty
                || image.title.localizedStandardContains(query)
                || image.keywords.contains { $0.localizedStandardContains(query) }
        }
        let start = (request.page - 1) * Self.pageSize
        let images = Array(matches.dropFirst(start).prefix(Self.pageSize))
        return .success(ImageSearchPageDTO(images: images, hasNextPage: start + images.count < matches.count))
    }
}
