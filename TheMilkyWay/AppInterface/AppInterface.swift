//
//  AppInterface.swift
//  TheMilkyWay
//

import CoreAPI
import CoreBase
import CoreLogic

// Private import: only the app target may see implementations.
private import CoreLogicImpl

@MainActor
private(set) var mainTargetImports: MainTargetImports = .unimplemented()

enum AppInterface {

    /// Which API the app talks to: the offline stubs or NASA's live API.
    enum ApiEnvironment {
        case stubs, live
    }

    /// The API each build talks to. To work offline from a Debug build, change `.debug` here (don't commit it).
    static func apiEnvironment(for appEnvironment: AppEnvironment) -> ApiEnvironment {
        switch appEnvironment {
        case .debug: .live
        case .release: .live
        }
    }

    /// Wires every module's imports for this build. Call once at launch, before the first screen is created.
    @MainActor
    static func setup(_ appEnvironment: AppEnvironment) {
        let apiManager = setupCoreAPIModule(apiEnvironment(for: appEnvironment))
        setupCoreLogicModule()
        mainTargetImports = MainTargetImports(
            apiManager: apiManager,
            favoritesService: CoreLogicImpl.coreLogicExports.favoritesService
        )
        setupExploreBaseModule()
        setupImageDetailsModule()
        setupFavoritesBaseModule()
        Log.info("Set up with \(apiEnvironment(for: appEnvironment)) API", .app)
    }
}

// MARK: Main target imports definition

struct MainTargetImports {
    let apiManager: ApiManager
    let favoritesService: FavoritesService

    @MainActor
    static func unimplemented() -> Self {
        MainTargetImports(apiManager: ApiManagerUnimplemented(), favoritesService: FavoritesServiceUnimplemented())
    }
}
