//
//  FavoritesBase+Dependencies.swift
//  FavoritesBase
//

import ComposableArchitecture
import CoreLogic

extension DependencyValues {

    var favoritesClient: FavoritesClient {
        get { self[FavoritesClient.self] }
        set { self[FavoritesClient.self] = newValue }
    }
}

@DependencyClient
struct FavoritesClient: DependencyKey {

    let service: @Sendable () async -> FavoritesService
    static var liveValue: Self {
        Self(service: { @MainActor in
            favoritesBaseImports.favoritesService
        })
    }
}
