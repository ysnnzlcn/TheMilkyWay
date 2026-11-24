//
//  ImageDetailsCore.swift
//  ImageDetails
//

import ComposableArchitecture
import CoreBase
import CoreTracker

/// One image: large picture, title, the favorite button, details and description. Pushed from Explore and
/// Favorites; it shows the image it was opened with (no request). The button follows the saved list while the
/// screen is open, so saving or removing the same image in the other tab shows here too. Saving or removing shows
/// a confirmation toast; a failed save shows the error toast and keeps the button as it was.
@Reducer
public struct ImageDetailsCore: Sendable {

    private enum CancelID {
        case favorites
    }

    @Dependency(\.favoritesClient) private var favoritesClient
    @Dependency(\.trackerClient) private var trackerClient

    public init() { }

    @ObservableState
    public struct State: Equatable, Sendable {
        // View State
        /// `nil` until the saved list arrives; the button shows once it is known.
        var isFavorite: Bool?
        var isSaving = false
        /// A save failed: error toast.
        var error: AppError?
        /// A save worked: confirmation toast.
        var confirmation: Confirmation?

        // Information State
        let image: NASAImageDTO

        public init(image: NASAImageDTO) {
            self.image = image
        }
    }

    public enum Confirmation: Equatable, Sendable {
        case added, removed
    }

    @CasePathable
    public enum Action: Equatable, Sendable {
        case onFirstAppear
        case onFavoriteTap
        case onToastDismiss
        /// The saved list, now and after every change.
        case onFavoritesChanged(Result<[NASAImageDTO], AppError>)
        /// The save finished; on success, whether the image is now a favorite.
        case onFavoriteSaved(Result<Bool, AppError>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onFirstAppear:
                return observeFavorites()

            case .onFavoriteTap:
                guard let isFavorite = state.isFavorite, !state.isSaving else { return .none }
                state.isSaving = true
                state.error = nil
                state.confirmation = nil
                return isFavorite ? remove(id: state.image.id) : add(state.image)

            case .onToastDismiss:
                state.error = nil
                state.confirmation = nil
                return .none

            case let .onFavoritesChanged(.success(images)):
                state.isFavorite = images.contains { $0.id == state.image.id }
                return .none

            case .onFavoritesChanged(.failure):
                // Unknown at first: offer to add (adding a saved image again only moves it to the top). Later, keep
                // what the button shows.
                state.isFavorite = state.isFavorite ?? false
                return .none

            case let .onFavoriteSaved(.success(isFavorite)):
                state.isSaving = false
                state.isFavorite = isFavorite
                state.confirmation = isFavorite ? .added : .removed
                return trackFavorite(isFavorite, imageID: state.image.id)

            case let .onFavoriteSaved(.failure(error)):
                state.isSaving = false
                state.error = error
                return .none
            }
        }
    }
}

// MARK: Tracking

private extension ImageDetailsCore {

    /// Only a save that worked; a failed one changed nothing.
    func trackFavorite(_ isFavorite: Bool, imageID: String) -> Effect<Action> {
        .run { _ in
            let event: ProductTrackerEvent = isFavorite
                ? .favoriteAdded(imageID: imageID)
                : .favoriteRemoved(imageID: imageID)
            await trackerClient.service().track(.product(event))
        }
    }
}

// MARK: Api calls

private extension ImageDetailsCore {

    /// The saved list for as long as the screen exists; popping the screen cancels it.
    func observeFavorites() -> Effect<Action> {
        .run { send in
            for await result in await favoritesClient.service().updates() {
                await send(.onFavoritesChanged(result))
            }
        }
        .cancellable(id: CancelID.favorites, cancelInFlight: true)
    }

    func add(_ image: NASAImageDTO) -> Effect<Action> {
        .run { send in
            let result = await favoritesClient.service().add(image)
            await send(.onFavoriteSaved(result.map { true }))
        }
    }

    func remove(id: String) -> Effect<Action> {
        .run { send in
            let result = await favoritesClient.service().remove(id: id)
            await send(.onFavoriteSaved(result.map { false }))
        }
    }
}
