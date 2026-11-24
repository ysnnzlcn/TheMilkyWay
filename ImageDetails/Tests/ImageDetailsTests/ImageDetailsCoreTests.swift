//
//  ImageDetailsCoreTests.swift
//  ImageDetailsTests
//

import ComposableArchitecture
import CoreBase
import CoreLogicMocks
import CoreTrackerMocks
import Testing
@testable import ImageDetails

@MainActor
struct ImageDetailsCoreTests {

    private let image = NASAImageDTO(id: "1", title: "Andromeda Galaxy")
    private let tracker = TrackerServiceMock()

    @Test func firstAppearShowsWhetherItIsSaved() async {
        let service = FavoritesServiceMock(favorites: [image])
        let store = makeTestStore(service: service)

        await store.send(.onFirstAppear)
        await store.receive(.onFavoritesChanged(.success([image]))) { $0.isFavorite = true }
        await end(store, service)
    }

    /// The same image open in both tabs: a change made in the other one shows here.
    @Test func changesMadeElsewhereUpdateTheButton() async {
        let service = FavoritesServiceMock()
        let store = makeTestStore(service: service)
        await store.send(.onFirstAppear)
        await store.receive(.onFavoritesChanged(.success([]))) { $0.isFavorite = false }

        _ = await service.add(image)
        await store.receive(.onFavoritesChanged(.success([image]))) { $0.isFavorite = true }

        _ = await service.remove(id: image.id)
        await store.receive(.onFavoritesChanged(.success([]))) { $0.isFavorite = false }
        await end(store, service)
    }

    @Test func failedReadOffersToAdd() async {
        let service = FavoritesServiceMock(failure: .storage)
        let store = makeTestStore(service: service)

        await store.send(.onFirstAppear)
        await store.receive(.onFavoritesChanged(.failure(.storage))) { $0.isFavorite = false }
        await end(store, service)
    }

    @Test func failedReadLaterKeepsTheButton() async {
        let store = makeTestStore(service: FavoritesServiceMock(), isFavorite: true)

        await store.send(.onFavoritesChanged(.failure(.storage)))
    }

    @Test func tapAddsAndConfirms() async {
        let service = FavoritesServiceMock()
        let store = makeTestStore(service: service, isFavorite: false)

        await store.send(.onFavoriteTap) { $0.isSaving = true }
        await store.receive(.onFavoriteSaved(.success(true))) {
            $0.isSaving = false
            $0.isFavorite = true
            $0.confirmation = .added
        }
        #expect(await service.favorites == [image])
        await store.finish()
        #expect(tracker.events == [.product(.favoriteAdded(imageID: "1"))])
    }

    @Test func tapRemovesAndConfirms() async {
        let service = FavoritesServiceMock(favorites: [image])
        let store = makeTestStore(service: service, isFavorite: true)

        await store.send(.onFavoriteTap) { $0.isSaving = true }
        await store.receive(.onFavoriteSaved(.success(false))) {
            $0.isSaving = false
            $0.isFavorite = false
            $0.confirmation = .removed
        }
        #expect(await service.removedIDs == ["1"])
        #expect(await service.favorites.isEmpty)
        await store.finish()
        #expect(tracker.events == [.product(.favoriteRemoved(imageID: "1"))])
    }

    @Test func failedSaveKeepsTheButtonAndShowsErrorUntilDismissed() async {
        let service = FavoritesServiceMock(failure: .storage)
        let store = makeTestStore(service: service, isFavorite: false)

        await store.send(.onFavoriteTap) { $0.isSaving = true }
        await store.receive(.onFavoriteSaved(.failure(.storage))) {
            $0.isSaving = false
            $0.error = .storage
        }
        #expect(await service.addedIDs == ["1"])
        await store.send(.onToastDismiss) { $0.error = nil }
        // A failed save changed nothing, so nothing is tracked.
        #expect(tracker.events.isEmpty)
    }

    @Test func tapDoesNothingWhileSavingOrBeforeTheStateIsKnown() async {
        var saving = ImageDetailsCore.State(image: image)
        saving.isFavorite = false
        saving.isSaving = true
        let unknown = ImageDetailsCore.State(image: image)

        for state in [saving, unknown] {
            let service = FavoritesServiceMock()
            let store = TestStore(initialState: state) {
                ImageDetailsCore()
            } withDependencies: { [tracker] in
                $0.favoritesClient = FavoritesClient(service: { service })
                $0.trackerClient = TrackerClient(service: { tracker })
            }

            await store.send(.onFavoriteTap)

            #expect(await service.addedIDs.isEmpty)
        }
    }

    @Test func newTapClearsTheLastToast() async {
        let store = makeTestStore(service: FavoritesServiceMock(favorites: [image]), isFavorite: true)
        await store.send(.onFavoriteTap) { $0.isSaving = true }
        await store.receive(.onFavoriteSaved(.success(false))) {
            $0.isSaving = false
            $0.isFavorite = false
            $0.confirmation = .removed
        }

        await store.send(.onFavoriteTap) {
            $0.isSaving = true
            $0.confirmation = nil
        }
        await store.receive(.onFavoriteSaved(.success(true))) {
            $0.isSaving = false
            $0.isFavorite = true
            $0.confirmation = .added
        }
    }

    // MARK: Helpers

    /// Ends the saved-list subscription the way the stream would, and checks nothing else is still running.
    private func end(_ store: TestStoreOf<ImageDetailsCore>, _ service: FavoritesServiceMock) async {
        await service.finishUpdates()
        await store.finish()
    }

    private func makeTestStore(
        service: FavoritesServiceMock,
        isFavorite: Bool? = nil
    ) -> TestStoreOf<ImageDetailsCore> {
        var state = ImageDetailsCore.State(image: image)
        state.isFavorite = isFavorite
        return TestStore(initialState: state) {
            ImageDetailsCore()
        } withDependencies: { [tracker] in
            $0.favoritesClient = FavoritesClient(service: { service })
            $0.trackerClient = TrackerClient(service: { tracker })
        }
    }
}
