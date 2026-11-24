//
//  FavoritesStoreTests.swift
//  CoreLogicTests
//

import CoreBase
import Foundation
import SwiftData
import Testing
@testable import CoreLogicImpl

/// The real store on disk, with the versioned schema and migration plan the app uses. If opening it failed, the app
/// would quietly keep favorites in memory only; these tests catch that.
struct FavoritesStoreTests {

    private let storeURL = URL.temporaryDirectory
        .appending(path: "FavoritesStoreTests-\(UUID().uuidString)")
        .appending(path: "Favorites.store")

    /// A store file in its own temporary folder.
    private func makeConfiguration() throws -> ModelConfiguration {
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        return ModelConfiguration(url: storeURL)
    }

    @Test func versionedStoreOpensOnDisk() throws {
        defer { removeStore() }

        _ = try CoreLogicExportsImpl.openFavoritesStore(try makeConfiguration())

        #expect(FileManager.default.fileExists(atPath: storeURL.path()))
    }

    @Test func savedFavoritesAreThereWhenTheStoreOpensAgain() async throws {
        defer { removeStore() }
        let image = NASAImageDTO(id: "PIA12235", title: "Nearside of the Moon", keywords: ["Moon"])

        let configuration = try makeConfiguration()
        let first = try CoreLogicExportsImpl.openFavoritesStore(configuration)
        _ = await FavoritesServiceImpl(makeContainer: { first }).add(image)

        // As after a relaunch: a new container and service on the same file.
        let second = try CoreLogicExportsImpl.openFavoritesStore(configuration)
        var updates = await FavoritesServiceImpl(makeContainer: { second }).updates().makeAsyncIterator()
        #expect(try await updates.next()?.get() == [image])
    }

    private func removeStore() {
        try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
    }
}
