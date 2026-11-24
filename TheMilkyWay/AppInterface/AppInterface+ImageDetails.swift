//
//  AppInterface+ImageDetails.swift
//  TheMilkyWay
//

import ImageDetails

extension AppInterface {

    @MainActor
    static func setupImageDetailsModule() {
        ImageDetails.imageDetailsImports = ImageDetailsImportsImpl(
            favoritesService: mainTargetImports.favoritesService
        )
    }
}
