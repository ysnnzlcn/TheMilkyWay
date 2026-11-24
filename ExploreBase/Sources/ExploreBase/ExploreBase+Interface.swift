//
//  ExploreBase+Interface.swift
//  ExploreBase
//

import CoreAPI
import CoreTracker

/// What this module needs. The app replaces it at launch (`AppInterface+ExploreBase`).
@MainActor
public var exploreBaseImports: ExploreBaseImports = ExploreBaseImportsImpl(
    imageSearchApi: ImageSearchApiUnimplemented(),
    trackerService: TrackerServiceUnimplemented()
)

// MARK: Imports

public protocol ExploreBaseImports: Sendable {
    var imageSearchApi: ImageSearchApi { get }
    var trackerService: TrackerService { get }
}

// MARK: ImportsImpl

public struct ExploreBaseImportsImpl: ExploreBaseImports {

    public let imageSearchApi: ImageSearchApi
    public let trackerService: TrackerService

    public init(imageSearchApi: ImageSearchApi, trackerService: TrackerService) {
        self.imageSearchApi = imageSearchApi
        self.trackerService = trackerService
    }
}
