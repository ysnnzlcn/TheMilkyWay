//
//  ImageSearchApiImpl.swift
//  CoreAPIImpl
//

import CoreAPI
import CoreBase

struct ImageSearchApiImpl: ImageSearchApi {

    static let pageSize = 50

    private let networkManager: any Requestable

    init(networkManager: any Requestable = NetworkManager()) {
        self.networkManager = networkManager
    }

    func searchImages(_ request: SearchImagesRequest) async -> Result<ImageSearchPageDTO, AppError> {
        if let error = request.validationError { return .failure(error) }
        let target = NASATarget.search(request, pageSize: Self.pageSize)
        return await networkManager.sendRequest(type: NASASearchResponseDTO.self, target: target)
            .map { $0.page(for: request, pageSize: Self.pageSize) }
    }
}
