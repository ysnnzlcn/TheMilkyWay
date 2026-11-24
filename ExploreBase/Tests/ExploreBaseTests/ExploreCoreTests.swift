//
//  ExploreCoreTests.swift
//  ExploreBaseTests
//

import ComposableArchitecture
import CoreAPI
import CoreBase
import ImageDetails
import Testing
@testable import ExploreBase

@MainActor
struct ExploreCoreTests {

    private let clock = TestClock()

    // MARK: First page

    @Test func firstAppearLoadsFeaturedTopic() async {
        let page = Self.page(["1", "2"], hasNextPage: true)
        let api = ImageSearchApiMock(result: .success(page))
        let store = makeTestStore(api: api)
        let request = SearchImagesRequest(query: "galaxy", page: 1)

        await store.send(.onFirstAppear) {
            $0.requestedQuery = "galaxy"
            $0.viewMode = .loading
        }
        await store.receive(.onGetImages(.success(page), request: request)) {
            $0.viewMode = .content
            $0.images = Self.images(["1", "2"])
            $0.nextPage = 2
            $0.shownQuery = "galaxy"
        }
        #expect(await api.requests == [request])
    }

    @Test func emptyAnswerShowsNoResults() async {
        let page = Self.page([])
        let store = makeTestStore(api: ImageSearchApiMock(result: .success(page)))

        await store.send(.onFirstAppear) {
            $0.requestedQuery = "galaxy"
            $0.viewMode = .loading
        }
        await store.receive(.onGetImages(.success(page), request: .init(query: "galaxy"))) {
            $0.viewMode = .content
            $0.shownQuery = "galaxy"
        }
        #expect(store.state.showsNoResults)
    }

    @Test func failedFirstPageShowsFullScreenError() async {
        let store = makeTestStore(api: ImageSearchApiMock(result: .failure(.api(.offline))))

        await store.send(.onFirstAppear) {
            $0.requestedQuery = "galaxy"
            $0.viewMode = .loading
        }
        await store.receive(.onGetImages(.failure(.api(.offline)), request: .init(query: "galaxy"))) {
            $0.viewMode = .content
            $0.loadError = .api(.offline)
        }
        #expect(!store.state.showsNoResults)
    }

    @Test func retryLoadsAgain() async {
        let page = Self.page(["1"])
        var state = ExploreCore.State()
        state.requestedQuery = "galaxy"
        state.loadError = .api(.offline)
        let store = makeTestStore(api: ImageSearchApiMock(result: .success(page)), state: state)

        await store.send(.onRetryTap) {
            $0.viewMode = .loading
            $0.loadError = nil
        }
        await store.receive(.onGetImages(.success(page), request: .init(query: "galaxy"))) {
            $0.viewMode = .content
            $0.images = Self.images(["1"])
            $0.shownQuery = "galaxy"
        }
    }

    // MARK: Search

    @Test func searchWaitsForTypingToPause() async {
        let page = Self.page(["1"])
        let api = ImageSearchApiMock(result: .success(page))
        let store = makeTestStore(api: api)

        await store.send(.onQueryChange("m")) { $0.query = "m" }
        await clock.advance(by: .milliseconds(200))
        await store.send(.onQueryChange("mo")) { $0.query = "mo" }
        await store.send(.onQueryChange("moon")) { $0.query = "moon" }
        await clock.advance(by: ExploreCore.typingPause)

        await store.receive(.onTypingPause) {
            $0.requestedQuery = "moon"
            $0.viewMode = .loading
        }
        await store.receive(.onGetImages(.success(page), request: .init(query: "moon"))) {
            $0.viewMode = .content
            $0.images = Self.images(["1"])
            $0.shownQuery = "moon"
        }
        #expect(await api.requests == [SearchImagesRequest(query: "moon", page: 1)])
    }

    @Test func clearingSearchReturnsToFeaturedTopic() async {
        let page = Self.page(["1"])
        let api = ImageSearchApiMock(result: .success(page))
        let store = makeTestStore(api: api, state: Self.shownState(query: "moon"))

        await store.send(.onQueryChange("")) { $0.query = "" }
        await clock.advance(by: ExploreCore.typingPause)

        await store.receive(.onTypingPause) {
            $0.requestedQuery = "galaxy"
            $0.viewMode = .loading
            $0.nextPage = nil
        }
        await store.receive(.onGetImages(.success(page), request: .init(query: "galaxy"))) {
            $0.viewMode = .content
            $0.images = Self.images(["1"])
            $0.shownQuery = "galaxy"
        }
    }

    @Test func newSearchCancelsTheRunningOne() async {
        let galaxy = Self.page(["1"])
        let moon = Self.page(["2"])
        let api = SlowImageSearchApi(clock: clock) { $0.query == "moon" ? moon : galaxy }
        let store = TestStore(initialState: ExploreCore.State()) {
            ExploreCore()
        } withDependencies: {
            $0.continuousClock = clock
            $0.imageSearchApiClient = ImageSearchApiClient(api: { api })
        }

        await store.send(.onFirstAppear) {
            $0.requestedQuery = "galaxy"
            $0.viewMode = .loading
        }
        await store.send(.onQueryChange("moon")) { $0.query = "moon" }
        await clock.advance(by: ExploreCore.typingPause)
        await store.receive(.onTypingPause) { $0.requestedQuery = "moon" }
        await clock.advance(by: SlowImageSearchApi.delay)

        // Only the newer search answers; the galaxy request was cancelled while running.
        await store.receive(.onGetImages(.success(moon), request: .init(query: "moon"))) {
            $0.viewMode = .content
            $0.images = Self.images(["2"])
            $0.shownQuery = "moon"
        }
    }

    @Test func sameSearchSendsNothing() async {
        let api = ImageSearchApiMock(result: .success(Self.page([])))
        let store = makeTestStore(api: api, state: Self.shownState(query: "moon"))

        await store.send(.onQueryChange("moon ")) { $0.query = "moon " }
        await clock.advance(by: ExploreCore.typingPause)

        #expect(await api.requests.isEmpty)
    }

    @Test func answerToOlderSearchIsIgnored() async {
        let store = makeTestStore(state: Self.shownState(query: "moon"))

        await store.send(.onGetImages(.success(Self.page(["9"])), request: .init(query: "galaxy")))
    }

    // MARK: Next pages

    @Test func listEndAppendsNextPageWithoutRepeats() async {
        let page = Self.page(["2", "3"])
        let api = ImageSearchApiMock(result: .success(page))
        let store = makeTestStore(api: api, state: Self.shownState(query: "galaxy"))

        await store.send(.onListEnd) { $0.isLoadingMore = true }
        await store.receive(.onGetImages(.success(page), request: .init(query: "galaxy", page: 2))) {
            $0.isLoadingMore = false
            $0.images = Self.images(["1", "2", "3"])
            $0.nextPage = nil
        }
        #expect(await api.requests == [SearchImagesRequest(query: "galaxy", page: 2)])
    }

    @Test func listEndDoesNothingWithoutNextPageOrWhileLoading() async {
        var lastPage = Self.shownState(query: "galaxy")
        lastPage.nextPage = nil
        var loadingMore = Self.shownState(query: "galaxy")
        loadingMore.isLoadingMore = true
        var searching = Self.shownState(query: "galaxy")
        searching.viewMode = .loading

        for state in [lastPage, loadingMore, searching] {
            let api = ImageSearchApiMock(result: .success(Self.page([])))
            let store = makeTestStore(api: api, state: state)

            await store.send(.onListEnd)

            #expect(await api.requests.isEmpty)
        }
    }

    @Test func failedNextPageShowsToastUntilDismissed() async {
        let store = makeTestStore(
            api: ImageSearchApiMock(result: .failure(.api(.server))),
            state: Self.shownState(query: "galaxy")
        )

        await store.send(.onListEnd) { $0.isLoadingMore = true }
        await store.receive(.onGetImages(.failure(.api(.server)), request: .init(query: "galaxy", page: 2))) {
            $0.isLoadingMore = false
            $0.error = .api(.server)
        }
        await store.send(.onToastDismiss) { $0.error = nil }
    }

    // MARK: Navigation

    @Test func imageTapPushesDetails() async {
        let store = makeTestStore(state: Self.shownState(query: "galaxy"))

        await store.send(.onImageTap(id: "1")) {
            $0.path[id: 0] = .imageDetails(ImageDetailsCore.State(image: Self.images(["1"])[0]))
        }
    }

    // MARK: Helpers

    private func makeTestStore(
        api: ImageSearchApiMock = ImageSearchApiMock(result: .success(page([]))),
        state: ExploreCore.State = .init()
    ) -> TestStoreOf<ExploreCore> {
        TestStore(initialState: state) {
            ExploreCore()
        } withDependencies: {
            $0.continuousClock = clock
            $0.imageSearchApiClient = ImageSearchApiClient(api: { api })
        }
    }

    /// Image "1" shown for `query`, with a second page to load.
    private static func shownState(query: String) -> ExploreCore.State {
        var state = ExploreCore.State()
        state.query = query == ExploreCore.featuredQuery ? "" : query
        state.requestedQuery = query
        state.shownQuery = query
        state.images = images(["1"])
        state.nextPage = 2
        return state
    }

    private static func images(_ ids: [String]) -> [NASAImageDTO] {
        ids.map { NASAImageDTO(id: $0, title: "Image \($0)") }
    }

    private static func page(_ ids: [String], hasNextPage: Bool = false) -> ImageSearchPageDTO {
        ImageSearchPageDTO(images: images(ids), totalHits: ids.count, hasNextPage: hasNextPage)
    }
}

/// Answers after `delay` on the test clock, so a request can still be running when the next one starts.
private struct SlowImageSearchApi: ImageSearchApi {

    static let delay: Duration = .seconds(1)

    let clock: TestClock<Duration>
    let page: @Sendable (SearchImagesRequest) -> ImageSearchPageDTO

    func searchImages(_ request: SearchImagesRequest) async -> Result<ImageSearchPageDTO, AppError> {
        do {
            try await clock.sleep(for: Self.delay)
            return .success(page(request))
        } catch {
            return .failure(.api(.cancelled))
        }
    }
}
