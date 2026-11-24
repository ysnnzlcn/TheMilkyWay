//
//  AppInterface+CoreUI.swift
//  TheMilkyWay
//

import CoreUI

extension AppInterface {

    @MainActor
    static func setupCoreUIModule() {
        CoreUI.coreUIImports = CoreUIImportsImpl(trackerService: mainTargetImports.trackerService)
    }
}
