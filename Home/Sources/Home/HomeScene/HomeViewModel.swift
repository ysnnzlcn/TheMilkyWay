//
//  HomeViewModel.swift
//
//
//  Created by Yasin Nazlican on 18.11.2021.
//

import Combine
import Core
import CoreUI

public enum HomeViewModelState {

    case toggleLoading(_ show: Bool)
    case itemSelected(_ item: NASAImage)
    case error(_ error: String)
}

@MainActor
public final class HomeViewModel {

    // MARK: Private Variables

    private let service: any NASAServices
    private var loadTask: Task<Void, Never>?

    // MARK: Public Variables

    @Published public private(set) var items = [NASAImage]()
    @Published public private(set) var state: HomeViewModelState = .toggleLoading(false)

    // MARK: Life-Cycle

    public init(service: any NASAServices) {
        self.service = service
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
        let result = await service.searchImages()
        guard !Task.isCancelled else { return }

        state = .toggleLoading(false)
        switch result {
        case .success(let response):
            items = response.collection.items
        case .failure(let error):
            state = .error(error.message)
        }
    }
}
