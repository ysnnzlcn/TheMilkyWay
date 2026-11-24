//
//  HomeViewModel.swift
//
//
//  Created by Yasin Nazlican on 18.11.2021.
//

import Combine
import CoreAPI
import CoreBase
import CoreUI

public enum HomeViewModelState {

    case toggleLoading(_ show: Bool)
    case itemSelected(_ item: NASAImageDTO)
    case error(_ error: String)
}

@MainActor
public final class HomeViewModel {

    // MARK: Private Variables

    private let imageSearchApi: any ImageSearchApi
    private var loadTask: Task<Void, Never>?

    // MARK: Public Variables

    @Published public private(set) var items = [NASAImageDTO]()
    @Published public private(set) var state: HomeViewModelState = .toggleLoading(false)

    // MARK: Life-Cycle

    public init(imageSearchApi: any ImageSearchApi) {
        self.imageSearchApi = imageSearchApi
    }

    // MARK: Public Methods

    public func didLoad() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.getImages()
        }
    }

    public func itemSelected(at index: Int) {
        state = .itemSelected(items[index])
    }

    isolated deinit {
        loadTask?.cancel()
    }
}

// MARK: Networking

public extension HomeViewModel {

    func getImages() async {
        state = .toggleLoading(true)
        let result = await imageSearchApi.searchImages(SearchImagesRequest(query: ""))
        guard !Task.isCancelled else { return }

        state = .toggleLoading(false)
        switch result {
        case .success(let page):
            items = page.images
        case .failure(let error):
            state = .error(error.message)
        }
    }
}
