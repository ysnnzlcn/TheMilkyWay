//
//  AppInterface+FavoritesBase.swift
//  TheMilkyWay
//

import FavoritesBase

extension AppInterface {

    @MainActor
    static func setupFavoritesBaseModule() {
        FavoritesBase.favoritesBaseImports = FavoritesBaseImportsImpl(
            favoritesService: mainTargetImports.favoritesService
        )
    }
}
