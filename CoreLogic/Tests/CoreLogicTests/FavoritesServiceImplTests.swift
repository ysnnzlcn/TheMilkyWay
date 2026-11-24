//
//  FavoritesServiceImplTests.swift
//  CoreLogicTests
//

import CoreBase
import Foundation
import SwiftData
import Synchronization
import Testing
@testable import CoreLogicImpl

struct FavoritesServiceImplTests {

    /// A clock that moves one second per save, so the order never depends on real time.
    private final class StepClock: Sendable {
        private let seconds = Mutex(0.0)

        func now() -> Date {
            seconds.withLock {
                $0 += 1
                return Date(timeIntervalSince1970: $0)
            }
        }
    }

    private func makeService() throws -> FavoritesServiceImpl {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteImageRecord.self, configurations: configuration)
        let clock = StepClock()
        return FavoritesServiceImpl(makeContainer: { container }, now: { clock.now() })
    }

    /// The list a new subscriber gets first: what is saved now.
    private func savedIDs(_ service: FavoritesServiceImpl) async throws -> [String]? {
        var updates = await service.updates().makeAsyncIterator()
        return try await updates.next()?.get().map(\.id)
    }

    private func image(_ id: String) -> NASAImageDTO {
        NASAImageDTO(
            id: id,
            title: "Image \(id)",
            description: "About \(id)",
            center: "JPL",
            credit: "NASA",
            dateCreated: Date(timeIntervalSince1970: 1_000),
            keywords: ["Moon"],
            thumbnailURL: URL(string: "https://example.com/\(id)~thumb.jpg"),
            imageURL: URL(string: "https://example.com/\(id)~medium.jpg")
        )
    }

    @Test func startsEmpty() async throws {
        let service = try makeService()

        #expect(try await savedIDs(service)?.isEmpty == true)
    }

    @Test func addedImagesComeBackWholeNewestFirst() async throws {
        let service = try makeService()

        _ = await service.add(image("1"))
        _ = await service.add(image("2"))

        var updates = await service.updates().makeAsyncIterator()
        #expect(try await updates.next()?.get() == [image("2"), image("1")])
    }

    @Test func addingAgainKeepsOneCopyAndMovesItToTop() async throws {
        let service = try makeService()
        _ = await service.add(image("1"))
        _ = await service.add(image("2"))

        _ = await service.add(image("1"))

        #expect(try await savedIDs(service) == ["1", "2"])
    }

    @Test func removeDeletesOnlyThatImage() async throws {
        let service = try makeService()
        _ = await service.add(image("1"))
        _ = await service.add(image("2"))

        let result = await service.remove(id: "1")

        #expect(throws: Never.self) { try result.get() }
        #expect(try await savedIDs(service) == ["2"])
    }

    @Test func subscribersGetEveryChange() async throws {
        let service = try makeService()
        var updates = await service.updates().makeAsyncIterator()
        #expect(try await updates.next()?.get().isEmpty == true)

        _ = await service.add(image("1"))
        #expect(try await updates.next()?.get().map(\.id) == ["1"])

        _ = await service.remove(id: "1")
        #expect(try await updates.next()?.get().isEmpty == true)
    }

    /// Two screens follow the list and one closes: the service lets the closed one go, and the other still gets
    /// every change.
    @Test func closedSubscriberIsDroppedAndOthersKeepGettingChanges() async throws {
        let service = try makeService()
        var staying = await service.updates().makeAsyncIterator()
        _ = try await staying.next()?.get()

        do {
            // A screen that read the list and then closed: its stream ends at the end of this scope.
            var leaving = await service.updates().makeAsyncIterator()
            _ = await leaving.next()
            #expect(await service.subscriberCount == 2)
        }
        #expect(await waitForSubscriberCount(1, in: service))

        _ = await service.add(image("1"))
        #expect(try await staying.next()?.get().map(\.id) == ["1"])
    }

    /// The service drops a closed stream on its own actor shortly after it ends.
    private func waitForSubscriberCount(_ count: Int, in service: FavoritesServiceImpl) async -> Bool {
        for _ in 0..<1_000 {
            if await service.subscriberCount == count { return true }
            await Task.yield()
        }
        return false
    }
}
