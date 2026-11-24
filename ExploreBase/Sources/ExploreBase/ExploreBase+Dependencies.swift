//
//  ExploreBase+Dependencies.swift
//  ExploreBase
//

import ComposableArchitecture
import CoreAPI
import CoreTracker

extension DependencyValues {

    var imageSearchApiClient: ImageSearchApiClient {
        get { self[ImageSearchApiClient.self] }
        set { self[ImageSearchApiClient.self] = newValue }
    }

    var trackerClient: TrackerClient {
        get { self[TrackerClient.self] }
        set { self[TrackerClient.self] = newValue }
    }
}

@DependencyClient
struct ImageSearchApiClient: DependencyKey {

    let api: @Sendable () async -> ImageSearchApi
    static var liveValue: Self {
        Self(api: { @MainActor in
            exploreBaseImports.imageSearchApi
        })
    }
}

@DependencyClient
struct TrackerClient: DependencyKey {

    let service: @Sendable () async -> TrackerService
    static var liveValue: Self {
        Self(service: { @MainActor in
            exploreBaseImports.trackerService
        })
    }
}
