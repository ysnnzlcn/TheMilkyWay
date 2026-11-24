//
//  ImageDetails+Interface.swift
//  ImageDetails
//

import CoreLogic
import CoreTracker

/// What this module needs. The app replaces it at launch (`AppInterface+ImageDetails`).
@MainActor
public var imageDetailsImports: ImageDetailsImports = ImageDetailsImportsImpl(
    favoritesService: FavoritesServiceUnimplemented(),
    trackerService: TrackerServiceUnimplemented()
)

// MARK: Imports

public protocol ImageDetailsImports: Sendable {
    var favoritesService: FavoritesService { get }
    var trackerService: TrackerService { get }
}

// MARK: ImportsImpl

public struct ImageDetailsImportsImpl: ImageDetailsImports {

    public let favoritesService: FavoritesService
    public let trackerService: TrackerService

    public init(favoritesService: FavoritesService, trackerService: TrackerService) {
        self.favoritesService = favoritesService
        self.trackerService = trackerService
    }
}
