//
//  FavoritesBase+Interface.swift
//  FavoritesBase
//

import CoreLogic

/// What this module needs. The app replaces it at launch (`AppInterface+FavoritesBase`).
@MainActor
public var favoritesBaseImports: FavoritesBaseImports = FavoritesBaseImportsImpl(
    favoritesService: FavoritesServiceUnimplemented()
)

// MARK: Imports

public protocol FavoritesBaseImports: Sendable {
    var favoritesService: FavoritesService { get }
}

// MARK: ImportsImpl

public struct FavoritesBaseImportsImpl: FavoritesBaseImports {

    public let favoritesService: FavoritesService

    public init(favoritesService: FavoritesService) {
        self.favoritesService = favoritesService
    }
}
