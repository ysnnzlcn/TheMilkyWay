//
//  ExploreCore.swift
//  ExploreBase
//

import ComposableArchitecture
import CoreBase
import CoreUI
import Foundation
import ImageDetails

/// NASA images in a paged grid, with search. An empty search shows the featured topic. A search starts once typing
/// pauses and replaces the one before it. A failed first page shows the full-screen "Try again"; a failed next page
/// the error Toast (reaching the end again retries). Tapping an image pushes its details.
@Reducer
public struct ExploreCore: Sendable {

    /// What Explore shows while the search field is empty.
    static let featuredQuery = "galaxy"
    /// Typing pauses this long before a search is sent.
    static let typingPause: Duration = .milliseconds(400)

    private enum CancelID {
        case typing
        case search
    }

    @Dependency(\.continuousClock) private var clock
    @Dependency(\.imageSearchApiClient) private var imageSearchApiClient

    public init() { }

    @ObservableState
    public struct State: Equatable, Sendable {
        // View State
        var viewMode: ViewMode = .content
        /// The first page failed: full-screen, with "Try again".
        var loadError: AppError?
        /// A next page failed: Toast.
        var error: AppError?
        var isLoadingMore = false

        // Information State
        /// The search field's text.
        var query = ""
        var images: [NASAImageDTO] = []
        /// `nil` before the first page and after the last.
        var nextPage: Int?
        /// The search the latest first page was asked for; answers to an older search are ignored.
        var requestedQuery: String?
        /// The search `images` answer; `nil` before any answer or after a failure.
        var shownQuery: String?
        var path = StackState<Path.State>()

        /// What is searched: the field's text, or the featured topic when it's empty.
        var searchQuery: String {
            let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? ExploreCore.featuredQuery : text
        }

        /// The search was answered with nothing.
        var showsNoResults: Bool {
            viewMode == .content && loadError == nil && images.isEmpty && shownQuery != nil
        }

        public init() { }
    }

    @CasePathable
    public enum Action: Equatable, Sendable {
        case onFirstAppear
        case onQueryChange(String)
        /// Typing paused: the search is sent.
        case onTypingPause
        /// "Try again" after a failed first page.
        case onRetryTap
        /// One of the last images appeared.
        case onListEnd
        case onImageTap(id: String)
        case onToastDismiss
        case onGetImages(Result<ImageSearchPageDTO, AppError>, request: SearchImagesRequest)
        case path(StackActionOf<Path>)
    }

    @Reducer
    public enum Path {
        case imageDetails(ImageDetailsCore)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onFirstAppear, .onRetryTap, .onTypingPause:
                return startSearch(&state)

            case let .onQueryChange(query):
                state.query = query
                // Same search as the one shown or loading (e.g. a space typed): nothing to send.
                guard state.searchQuery != state.requestedQuery else { return .cancel(id: CancelID.typing) }
                return .run { send in
                    try await clock.sleep(for: Self.typingPause)
                    await send(.onTypingPause)
                }
                .cancellable(id: CancelID.typing, cancelInFlight: true)

            case .onListEnd:
                let canLoadMore = !state.isLoadingMore && state.viewMode == .content
                guard canLoadMore, let page = state.nextPage, let query = state.requestedQuery else { return .none }
                state.isLoadingMore = true
                return getImages(SearchImagesRequest(query: query, page: page))

            case let .onImageTap(id):
                guard let image = state.images.first(where: { $0.id == id }) else { return .none }
                state.path.append(.imageDetails(ImageDetailsCore.State(image: image)))
                return .none

            case .onToastDismiss:
                state.error = nil
                return .none

            case let .onGetImages(result, request):
                guard request.query == state.requestedQuery else { return .none }
                onGetImages(result, request: request, state: &state)
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension ExploreCore.Path.State: Equatable, Sendable {}
extension ExploreCore.Path.Action: Equatable, Sendable {}

// MARK: State changes

private extension ExploreCore {

    /// Asks for the first page of the current search; a search still running is cancelled.
    func startSearch(_ state: inout State) -> Effect<Action> {
        state.requestedQuery = state.searchQuery
        state.viewMode = .loading
        state.loadError = nil
        state.isLoadingMore = false
        state.nextPage = nil
        return .merge(
            .cancel(id: CancelID.typing),
            getImages(SearchImagesRequest(query: state.searchQuery, page: 1), cancelsRunning: true)
        )
    }

    func onGetImages(_ result: Result<ImageSearchPageDTO, AppError>, request: SearchImagesRequest, state: inout State) {
        // A cancelled request was replaced by a newer one, which owns the state now.
        if case .failure(.api(.cancelled)) = result { return }
        let isFirstPage = request.page == 1
        state.viewMode = .content
        state.isLoadingMore = false

        switch result {
        case let .success(page):
            let earlier = isFirstPage ? [] : state.images
            // NASA can repeat an image across pages; the grid needs each id once.
            let known = Set(earlier.map(\.id))
            var seen = Set<String>()
            let new = page.images.filter { !known.contains($0.id) && seen.insert($0.id).inserted }
            state.images = earlier + new
            state.nextPage = page.hasNextPage ? request.page + 1 : nil
            state.shownQuery = request.query

        case let .failure(error) where isFirstPage:
            state.images = []
            state.shownQuery = nil
            state.loadError = error

        case let .failure(error):
            state.error = error
        }
    }
}

// MARK: Api calls

private extension ExploreCore {

    func getImages(_ request: SearchImagesRequest, cancelsRunning: Bool = false) -> Effect<Action> {
        .run { send in
            let result = await imageSearchApiClient.api().searchImages(request)
            await send(.onGetImages(result, request: request))
        }
        .cancellable(id: CancelID.search, cancelInFlight: cancelsRunning)
    }
}
