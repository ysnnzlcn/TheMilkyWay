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
        /// The search the latest first page was asked for; next pages ask for the same one.
        var requestedQuery: String?
        /// A first page arrived and nothing failed since.
        var hasLoaded = false
        var path = StackState<Path.State>()

        /// What is searched: the field's text, or the featured topic when it's empty.
        var searchQuery: String {
            let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? ExploreCore.featuredQuery : text
        }

        /// The search was answered with nothing.
        var showsNoResults: Bool {
            viewMode == .content && loadError == nil && images.isEmpty && hasLoaded
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
        /// The tab was tapped again: back to the grid.
        case popToRoot
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
                return onQueryChange(query, state: &state)

            case .onListEnd:
                return loadNextPage(&state)

            case let .onImageTap(id):
                guard let image = state.images.first(where: { $0.id == id }) else { return .none }
                state.path.append(.imageDetails(ImageDetailsCore.State(image: image)))
                return .none

            case .onToastDismiss:
                state.error = nil
                return .none

            case .popToRoot:
                state.path.removeAll()
                return .none

            case let .onGetImages(result, request):
                // No check for an older search's answer: starting a search cancels the running request, and a
                // cancelled effect never sends.
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

    /// Waits for typing to pause before searching; each new letter restarts the wait.
    func onQueryChange(_ query: String, state: inout State) -> Effect<Action> {
        state.query = query
        // Same search as the one shown or loading (e.g. a space typed): nothing to send.
        guard state.searchQuery != state.requestedQuery else { return .cancel(id: CancelID.typing) }
        return .run { send in
            try await clock.sleep(for: Self.typingPause)
            await send(.onTypingPause)
        }
        .cancellable(id: CancelID.typing, cancelInFlight: true)
    }

    /// Asks for the next page, unless there is none or a load is already running.
    func loadNextPage(_ state: inout State) -> Effect<Action> {
        let canLoadMore = !state.isLoadingMore && state.viewMode == .content
        guard canLoadMore, let page = state.nextPage, let query = state.requestedQuery else { return .none }
        state.isLoadingMore = true
        return getImages(SearchImagesRequest(query: query, page: page))
    }

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
            state.hasLoaded = true

        case let .failure(error) where isFirstPage:
            state.images = []
            state.hasLoaded = false
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
