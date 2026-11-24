//
//  ExploreView.swift
//  ExploreBase
//

import ComposableArchitecture
import CoreAssets
import CoreBase
import CoreUI
import ImageDetails
import SwiftUI

/// Native large title "Explore" with the search field under it, then the image grid. While a search loads, the grid
/// fades and a spinner shows; a failed load or no results cover it with a full-screen message.
public struct ExploreView: View {

    @Bindable private var store: StoreOf<ExploreCore>

    public init(store: StoreOf<ExploreCore>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            BaseContentView(mode: store.viewMode) {
                InfiniteImageGrid(
                    items: cards,
                    isLoadingMore: store.isLoadingMore,
                    // A new search starts at the top, not where the old results were scrolled to.
                    scrollResetID: store.requestedQuery,
                    onTap: { store.send(.onImageTap(id: $0)) },
                    onListEnd: { store.send(.onListEnd) }
                )
            }
            .headerMessage(message)
            .toast(model: ToastUIModel(error: store.error) { store.send(.onToastDismiss) })
            .navigationTitle(L10n.Explore.title)
            .searchable(text: $store.query.sending(\.onQueryChange), prompt: L10n.Explore.searchPrompt)
            .onFirstAppear { store.send(.onFirstAppear) }
        } destination: { store in
            switch store.case {
            case let .imageDetails(store):
                ImageDetailsView(store: store)
            }
        }
    }
}

// MARK: UI mapping

private extension ExploreView {

    var cards: [ImageCard.UIModel] {
        store.images.map(ImageCard.UIModel.init(image:))
    }

    /// A failed first page, else "No results", else nothing.
    var message: HeaderMessage.UIModel? {
        if let loadError = store.loadError {
            return HeaderMessage.UIModel(error: loadError) { store.send(.onRetryTap) }
        }
        guard store.showsNoResults else { return nil }
        return HeaderMessage.UIModel(
            title: L10n.Explore.noResultsTitle,
            description: L10n.Explore.noResultsDescription,
            systemImage: .magnifyingglass
        )
    }
}
