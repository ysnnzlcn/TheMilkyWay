//
//  NetworkManagerTests.swift
//  CoreAPITests
//

import CoreBase
import Foundation
import Synchronization
import Testing
@testable import CoreAPIImpl

@Suite(.serialized)
struct NetworkManagerTests {

    private struct Payload: Decodable, Equatable, Sendable {
        let value: String
    }

    private struct Target: NetworkTarget {
        var baseURL = "https://example.com/"
        var path = "search"
        var requestTimeout: TimeInterval?
        var method: HTTPMethod = .get
        var headers: [String: String]?
        var body: Data?
        var queryItems: [URLQueryItem] = [.init(name: "q", value: "moon")]
    }

    private func makeManager() -> NetworkManager {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return NetworkManager(session: URLSession(configuration: configuration))
    }

    @Test func successDecodesResponseAndBuildsRequest() async {
        StubURLProtocol.stub(.response(status: 200, body: #"{"value":"ok"}"#))

        let result = await makeManager().sendRequest(type: Payload.self, target: Target())

        #expect(result == .success(Payload(value: "ok")))
        #expect(StubURLProtocol.lastRequestURL?.absoluteString == "https://example.com/search?q=moon")
    }

    @Test func queryEncodesPlusAndAmpersand() async {
        StubURLProtocol.stub(.response(status: 200, body: #"{"value":"ok"}"#))
        let target = Target(queryItems: [.init(name: "q", value: "c++ a&b")])

        _ = await makeManager().sendRequest(type: Payload.self, target: target)

        #expect(StubURLProtocol.lastRequestURL?.query(percentEncoded: true) == "q=c%2B%2B%20a%26b")
    }

    /// Request, decoding and mapping together, as the app runs them.
    @Test func imageSearchLoadsPageFromResponse() async throws {
        let body = String(decoding: try Fixture.searchResponse(), as: UTF8.self)
        StubURLProtocol.stub(.response(status: 200, body: body))
        let api = ImageSearchApiImpl(networkManager: makeManager())

        let page = try await api.searchImages(SearchImagesRequest(query: "moon", page: 2)).get()

        #expect(page.images.map(\.id) == ["PIA12235", "SPARSE-1"])
        #expect(page.totalHits == 3)
        #expect(!page.hasNextPage)
        let query = StubURLProtocol.lastRequestURL?.query(percentEncoded: true)
        #expect(query == "q=moon&media_type=image&page=2&page_size=\(ImageSearchApiImpl.pageSize)")
    }

    @Test func serverStatusReturnsServerError() async {
        StubURLProtocol.stub(.response(status: 500, body: "{}"))

        let result = await makeManager().sendRequest(type: Payload.self, target: Target())

        #expect(result == .failure(.api(.server)))
    }

    @Test func invalidBodyReturnsDecodingError() async {
        StubURLProtocol.stub(.response(status: 200, body: "not json"))

        let result = await makeManager().sendRequest(type: Payload.self, target: Target())

        #expect(result == .failure(.api(.decoding)))
    }

    @Test(arguments: [
        (URLError.Code.notConnectedToInternet, AppError.Kind.offline),
        (URLError.Code.timedOut, AppError.Kind.timeout),
        (URLError.Code.cancelled, AppError.Kind.cancelled),
        (URLError.Code.badServerResponse, AppError.Kind.server),
    ])
    func urlErrorsMapToKinds(code: URLError.Code, kind: AppError.Kind) async {
        StubURLProtocol.stub(.failure(code))

        let result = await makeManager().sendRequest(type: Payload.self, target: Target())

        #expect(result == .failure(.api(kind)))
    }

    @Test func invalidURLReturnsUnexpectedError() async {
        let target = Target(baseURL: "https://exa mple.com/")

        let result = await makeManager().sendRequest(type: Payload.self, target: target)

        guard case .failure(.unexpected) = result else {
            Issue.record("Expected an unexpected error")
            return
        }
    }
}

private final class StubURLProtocol: URLProtocol, @unchecked Sendable {

    enum Outcome: Sendable {
        case response(status: Int, body: String)
        case failure(URLError.Code)
    }

    private struct State: Sendable {
        var outcome: Outcome?
        var lastRequestURL: URL?
    }

    private static let state = Mutex(State())

    static var lastRequestURL: URL? {
        state.withLock { $0.lastRequestURL }
    }

    static func stub(_ outcome: Outcome) {
        state.withLock { $0 = State(outcome: outcome) }
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let outcome = Self.state.withLock { state in
            state.lastRequestURL = request.url
            return state.outcome
        }

        switch outcome {
        case .response(let status, let body):
            let response = request.url.flatMap {
                HTTPURLResponse(url: $0, statusCode: status, httpVersion: nil, headerFields: nil)
            }
            guard let response else { return }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Data(body.utf8))
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let code):
            client?.urlProtocol(self, didFailWithError: URLError(code))
        case nil:
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
        }
    }

    override func stopLoading() {}
}
