//
//  ExploreBase+Interface.swift
//  ExploreBase
//

import CoreAPI

/// What this module needs. The app replaces it at launch (`AppInterface+ExploreBase`).
@MainActor
public var exploreBaseImports: ExploreBaseImports = ExploreBaseImportsImpl(
    imageSearchApi: ImageSearchApiUnimplemented()
)

// MARK: Imports

public protocol ExploreBaseImports: Sendable {
    var imageSearchApi: ImageSearchApi { get }
}

// MARK: ImportsImpl

public struct ExploreBaseImportsImpl: ExploreBaseImports {

    public let imageSearchApi: ImageSearchApi

    public init(imageSearchApi: ImageSearchApi) {
        self.imageSearchApi = imageSearchApi
    }
}
