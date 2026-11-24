//
//  FavoritesCore.swift
//  FavoritesBase
//

import ComposableArchitecture
import CoreBase
import CoreUI
import ImageDetails

/// The saved images, newest first, in the same grid as Explore. It follows the saved list live: saving or removing
/// an image anywhere updates it, with no reload. Tapping an image pushes its details (where it can be removed).
/// Nothing saved shows an empty state. A failed first read shows the full-screen "Try again"; a later failed read
/// keeps the list and shows the error Toast.
@Reducer
public struct FavoritesCore: Sendable {

    private enum CancelID {
        case updates
    }

    @Dependency(\.favoritesClient) private var favoritesClient

    public init() { }

    @ObservableState
    public struct State: Equatable, Sendable {
        // View State
        var viewMode: ViewMode = .content
        /// The saved list couldn't be read at first: full-screen, with "Try again".
        var loadError: AppError?
        /// A later read failed: Toast, and the list stays as it was.
        var error: AppError?

        // Information State
        var images: [NASAImageDTO] = []
        /// The saved list arrived at least once.
        var hasLoaded = false
        var path = StackState<Path.State>()

        /// Nothing is saved.
        var showsEmpty: Bool {
            hasLoaded && loadError == nil && images.isEmpty
        }

        public init() { }
    }

    @CasePathable
    public enum Action: Equatable, Sendable {
        case onFirstAppear
        /// "Try again" after a failed read.
        case onRetryTap
        case onImageTap(id: String)
        /// The tab was tapped again: back to the list.
        case popToRoot
        case onToastDismiss
        case onFavoritesChanged(Result<[NASAImageDTO], AppError>)
        case path(StackActionOf<Path>)
    }

    @Reducer
    public enum Path {
        case imageDetails(ImageDetailsCore)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onFirstAppear, .onRetryTap:
                state.viewMode = .loading
                state.loadError = nil
                return observeFavorites()

            case let .onImageTap(id):
                guard let image = state.images.first(where: { $0.id == id }) else { return .none }
                state.path.append(.imageDetails(ImageDetailsCore.State(image: image)))
                return .none

            case .popToRoot:
                state.path.removeAll()
                return .none

            case .onToastDismiss:
                state.error = nil
                return .none

            case let .onFavoritesChanged(result):
                onFavoritesChanged(result, state: &state)
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension FavoritesCore.Path.State: Equatable, Sendable {}
extension FavoritesCore.Path.Action: Equatable, Sendable {}

// MARK: State changes

private extension FavoritesCore {

    func onFavoritesChanged(_ result: Result<[NASAImageDTO], AppError>, state: inout State) {
        switch result {
        case let .success(images):
            state.viewMode = .content
            state.hasLoaded = true
            state.loadError = nil
            state.images = images

        case let .failure(error) where state.hasLoaded:
            // The list shown is still right; only this read failed.
            state.error = error

        case let .failure(error):
            state.viewMode = .content
            state.loadError = error
        }
    }
}

// MARK: Api calls

private extension FavoritesCore {

    /// Every change to the saved list, for as long as the screen exists. "Try again" starts a new subscription.
    func observeFavorites() -> Effect<Action> {
        .run { send in
            for await result in await favoritesClient.service().updates() {
                await send(.onFavoritesChanged(result))
            }
        }
        .cancellable(id: CancelID.updates, cancelInFlight: true)
    }
}
