//
//  FavoritesView.swift
//  FavoritesBase
//

import ComposableArchitecture
import CoreAssets
import CoreBase
import CoreUI
import ImageDetails
import SwiftUI

/// Native large title "Favorites", then the saved images in the image grid. Nothing saved or a failed read cover it
/// with a full-screen message.
public struct FavoritesView: View {

    @Bindable private var store: StoreOf<FavoritesCore>

    public init(store: StoreOf<FavoritesCore>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            BaseContentView(mode: store.viewMode) {
                // Every saved image is already loaded: no paging.
                InfiniteImageGrid(items: cards, onTap: { store.send(.onImageTap(id: $0)) })
            }
            .headerMessage(message)
            .toast(model: ToastUIModel(error: store.error) { store.send(.onToastDismiss) })
            .navigationTitle(L10n.Favorites.title)
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

private extension FavoritesView {

    var cards: [ImageCard.UIModel] {
        store.images.map(ImageCard.UIModel.init(image:))
    }

    /// A failed read, else the empty state, else nothing.
    var message: HeaderMessage.UIModel? {
        if let loadError = store.loadError {
            return HeaderMessage.UIModel(error: loadError) { store.send(.onRetryTap) }
        }
        guard store.showsEmpty else { return nil }
        return HeaderMessage.UIModel(
            title: L10n.Favorites.emptyTitle,
            description: L10n.Favorites.emptyDescription,
            systemImage: .heart
        )
    }
}
