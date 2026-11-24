//
//  FavoritesCoreTests.swift
//  FavoritesBaseTests
//

import ComposableArchitecture
import CoreBase
import CoreLogicMocks
import ImageDetails
import Testing
@testable import FavoritesBase

/// The saved-list subscription lives as long as the screen, so each test ends the mock's streams and waits for it.
@MainActor
struct FavoritesCoreTests {

    private let andromeda = NASAImageDTO(id: "1", title: "Andromeda Galaxy")
    private let moon = NASAImageDTO(id: "2", title: "Full Moon")

    @Test func firstAppearShowsSavedImages() async {
        let service = FavoritesServiceMock(favorites: [moon, andromeda])
        let store = makeTestStore(service: service)

        await store.send(.onFirstAppear) { $0.viewMode = .loading }
        await store.receive(.onFavoritesChanged(.success([moon, andromeda]))) {
            $0.viewMode = .content
            $0.hasLoaded = true
            $0.images = [moon, andromeda]
        }
        await end(store, service)
    }

    @Test func nothingSavedShowsEmptyState() async {
        let service = FavoritesServiceMock()
        let store = makeTestStore(service: service)

        await store.send(.onFirstAppear) { $0.viewMode = .loading }
        await store.receive(.onFavoritesChanged(.success([]))) {
            $0.viewMode = .content
            $0.hasLoaded = true
        }
        #expect(store.state.showsEmpty)
        await end(store, service)
    }

    @Test func savingOrRemovingElsewhereUpdatesTheList() async {
        let service = FavoritesServiceMock(favorites: [andromeda])
        let store = makeTestStore(service: service)
        await store.send(.onFirstAppear) { $0.viewMode = .loading }
        await store.receive(.onFavoritesChanged(.success([andromeda]))) {
            $0.viewMode = .content
            $0.hasLoaded = true
            $0.images = [andromeda]
        }

        _ = await service.add(moon)
        await store.receive(.onFavoritesChanged(.success([moon, andromeda]))) { $0.images = [moon, andromeda] }

        _ = await service.remove(id: "1")
        await store.receive(.onFavoritesChanged(.success([moon]))) { $0.images = [moon] }
        await end(store, service)
    }

    @Test func failedReadShowsFullScreenErrorAndRetryReadsAgain() async {
        let service = FavoritesServiceMock(favorites: [andromeda], failure: .storage)
        let store = makeTestStore(service: service)

        await store.send(.onFirstAppear) { $0.viewMode = .loading }
        await store.receive(.onFavoritesChanged(.failure(.storage))) {
            $0.viewMode = .content
            $0.loadError = .storage
        }
        #expect(!store.state.showsEmpty)

        await service.setFailure(nil)
        await store.send(.onRetryTap) {
            $0.viewMode = .loading
            $0.loadError = nil
        }
        await store.receive(.onFavoritesChanged(.success([andromeda]))) {
            $0.viewMode = .content
            $0.hasLoaded = true
            $0.images = [andromeda]
        }
        await end(store, service)
    }

    @Test func laterFailedReadKeepsTheListAndShowsToastUntilDismissed() async {
        var state = FavoritesCore.State()
        state.hasLoaded = true
        state.images = [andromeda]
        let store = makeTestStore(service: FavoritesServiceMock(), state: state)

        await store.send(.onFavoritesChanged(.failure(.storage))) { $0.error = .storage }
        await store.send(.onToastDismiss) { $0.error = nil }
    }

    @Test func imageTapPushesDetailsAndPopToRootGoesBack() async {
        var state = FavoritesCore.State()
        state.images = [andromeda]
        let store = makeTestStore(service: FavoritesServiceMock(), state: state)

        await store.send(.onImageTap(id: "1")) {
            $0.path[id: 0] = .imageDetails(ImageDetailsCore.State(image: andromeda))
        }
        await store.send(.popToRoot) { $0.path = StackState() }
    }

    /// The back button: the details screen is popped from the stack.
    @Test func backFromDetailsPopsIt() async {
        var state = FavoritesCore.State()
        state.images = [andromeda]
        let store = makeTestStore(service: FavoritesServiceMock(), state: state)
        await store.send(.onImageTap(id: "1")) {
            $0.path[id: 0] = .imageDetails(ImageDetailsCore.State(image: andromeda))
        }

        await store.send(.path(.popFrom(id: 0))) { $0.path = StackState() }
    }

    // MARK: Helpers

    /// Ends the subscription the way the stream would, and checks nothing else is still running.
    private func end(_ store: TestStoreOf<FavoritesCore>, _ service: FavoritesServiceMock) async {
        await service.finishUpdates()
        await store.finish()
    }

    private func makeTestStore(
        service: FavoritesServiceMock,
        state: FavoritesCore.State = .init()
    ) -> TestStoreOf<FavoritesCore> {
        TestStore(initialState: state) {
            FavoritesCore()
        } withDependencies: {
            $0.favoritesClient = FavoritesClient(service: { service })
        }
    }
}
