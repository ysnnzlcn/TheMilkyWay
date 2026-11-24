//
//  ImageDetails+Dependencies.swift
//  ImageDetails
//

import ComposableArchitecture
import CoreLogic
import CoreTracker

extension DependencyValues {

    var favoritesClient: FavoritesClient {
        get { self[FavoritesClient.self] }
        set { self[FavoritesClient.self] = newValue }
    }

    var trackerClient: TrackerClient {
        get { self[TrackerClient.self] }
        set { self[TrackerClient.self] = newValue }
    }
}

@DependencyClient
struct FavoritesClient: DependencyKey {

    let service: @Sendable () async -> FavoritesService
    static var liveValue: Self {
        Self(service: { @MainActor in
            imageDetailsImports.favoritesService
        })
    }
}

@DependencyClient
struct TrackerClient: DependencyKey {

    let service: @Sendable () async -> TrackerService
    static var liveValue: Self {
        Self(service: { @MainActor in
            imageDetailsImports.trackerService
        })
    }
}
