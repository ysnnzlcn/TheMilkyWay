//
//  ExploreBase+Dependencies.swift
//  ExploreBase
//

import ComposableArchitecture
import CoreAPI

extension DependencyValues {

    var imageSearchApiClient: ImageSearchApiClient {
        get { self[ImageSearchApiClient.self] }
        set { self[ImageSearchApiClient.self] = newValue }
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
