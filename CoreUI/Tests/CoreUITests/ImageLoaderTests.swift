//
//  ImageLoaderTests.swift
//  CoreUITests
//

import Foundation
import Synchronization
import Testing
import UIKit
@testable import CoreUI

@Suite(.serialized)
struct ImageLoaderTests {

    private let url = URL(string: "https://example.com/image.png") ?? URL.temporaryDirectory

    private func makeLoader() -> ImageLoader {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ImageStubURLProtocol.self]
        configuration.urlCache = nil
        return ImageLoader(session: URLSession(configuration: configuration), cache: ImageMemoryCache())
    }

    @Test func decodesAtRequestedSize() async throws {
        ImageStubURLProtocol.stub(status: 200, data: Self.png(width: 400, height: 200))

        let image = try #require(await makeLoader().image(for: url, maxPixelSize: 100))

        #expect(image.cgImage?.width == 100)
        #expect(image.cgImage?.height == 50)
    }

    @Test func secondLoadComesFromMemory() async {
        ImageStubURLProtocol.stub(status: 200, data: Self.png(width: 40, height: 40))
        let loader = makeLoader()

        _ = await loader.image(for: url, maxPixelSize: 100)
        let image = await loader.image(for: url, maxPixelSize: 100)

        #expect(image != nil)
        #expect(ImageStubURLProtocol.requestsCount == 1)
    }

    @Test func cachedImageIsOnlyWhatWasLoadedAtThatSize() async {
        ImageStubURLProtocol.stub(status: 200, data: Self.png(width: 40, height: 40))
        let loader = makeLoader()

        #expect(loader.cachedImage(for: url, maxPixelSize: 100) == nil)
        _ = await loader.image(for: url, maxPixelSize: 100)

        #expect(loader.cachedImage(for: url, maxPixelSize: 100) != nil)
        #expect(loader.cachedImage(for: url, maxPixelSize: 200) == nil)
    }

    @Test func serverErrorReturnsNil() async {
        ImageStubURLProtocol.stub(status: 404, data: Self.png(width: 40, height: 40))

        let image = await makeLoader().image(for: url, maxPixelSize: 100)

        #expect(image == nil)
    }

    @Test func invalidDataReturnsNil() async {
        ImageStubURLProtocol.stub(status: 200, data: Data("not an image".utf8))

        let image = await makeLoader().image(for: url, maxPixelSize: 100)

        #expect(image == nil)
    }

    private static func png(width: Int, height: Int) -> Data {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        return renderer.pngData { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
}

private final class ImageStubURLProtocol: URLProtocol, @unchecked Sendable {

    private struct State: Sendable {
        var status = 200
        var data = Data()
        var requestsCount = 0
    }

    private static let state = Mutex(State())

    static var requestsCount: Int {
        state.withLock { $0.requestsCount }
    }

    static func stub(status: Int, data: Data) {
        state.withLock { $0 = State(status: status, data: data) }
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let (status, data) = Self.state.withLock { state in
            state.requestsCount += 1
            return (state.status, state.data)
        }
        let response = request.url.flatMap {
            HTTPURLResponse(url: $0, statusCode: status, httpVersion: nil, headerFields: nil)
        }
        guard let response else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
