//
//  AppInterface+ExploreBase.swift
//  TheMilkyWay
//

import ExploreBase

extension AppInterface {

    @MainActor
    static func setupExploreBaseModule() {
        ExploreBase.exploreBaseImports = ExploreBaseImportsImpl(
            imageSearchApi: mainTargetImports.apiManager.imageSearch,
            trackerService: mainTargetImports.trackerService
        )
    }
}
