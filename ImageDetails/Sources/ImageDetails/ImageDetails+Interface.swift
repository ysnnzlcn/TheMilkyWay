//
//  ImageDetails+Interface.swift
//  ImageDetails
//

import CoreLogic

/// What this module needs. The app replaces it at launch (`AppInterface+ImageDetails`).
@MainActor
public var imageDetailsImports: ImageDetailsImports = ImageDetailsImportsImpl(
    favoritesService: FavoritesServiceUnimplemented()
)

// MARK: Imports

public protocol ImageDetailsImports: Sendable {
    var favoritesService: FavoritesService { get }
}

// MARK: ImportsImpl

public struct ImageDetailsImportsImpl: ImageDetailsImports {

    public let favoritesService: FavoritesService

    public init(favoritesService: FavoritesService) {
        self.favoritesService = favoritesService
    }
}
