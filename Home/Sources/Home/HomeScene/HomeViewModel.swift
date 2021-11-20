//
//  HomeViewModel.swift
//  
//
//  Created by Yasin Nazlican on 18.11.2021.
//

import Combine
import Core

enum HomeViewModelState {

    case toggleLoading(_ show: Bool)
    case itemSelected(_ item: NASAImage)
    case error(_ error: String)
}

public final class HomeViewModel {

    // MARK: Private Variables

    private let service: NASAServices
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Variables

    @Published private(set) var items = [ImageTableCellViewModel]()
    @Published private(set) var state: HomeViewModelState = .toggleLoading(false)

    // MARK: Life-Cycle

    public init(service: NASAServices) {
        self.service = service
    }

    // MARK: Public Methods

    public func didLoad() {
        getImages()
    }

    func itemSelected(at index: Int) {
        state = .itemSelected(items[index].imageModel)
    }
}

// MARK: Networking

extension HomeViewModel {

    private func getImages() {
        state = .toggleLoading(true)
        service
            .searchImages()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.state = .error(error.customDescription)

                case .finished:
                    self?.state = .toggleLoading(false)
                }
            }, receiveValue: { [weak self] response in
                self?.items = response.collection.items.map { ImageTableCellViewModel(model: $0) }
            })
            .store(in: &cancellables)
    }
}
