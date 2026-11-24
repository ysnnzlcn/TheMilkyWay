//
//  CoreLogic+Interface.swift
//  CoreLogicImpl
//

import CoreBase
import CoreLogic
import SwiftData

@MainActor
public var coreLogicExports: CoreLogicExports = CoreLogicExportsImpl.unimplemented()

// MARK: - Exports

public protocol CoreLogicExports: Sendable {
    var favoritesService: FavoritesService { get }
}

// MARK: - ExportsImpl

public struct CoreLogicExportsImpl: CoreLogicExports {

    public let favoritesService: FavoritesService

    /// Builds the services only; the favorites store opens on its first use, off the main thread.
    public init() {
        self.favoritesService = FavoritesServiceImpl(makeContainer: Self.makeFavoritesContainer)
    }

    private init(favoritesService: FavoritesService) {
        self.favoritesService = favoritesService
    }

    /// The default before `AppInterface.setup` runs: any use fails with "Not implemented".
    static func unimplemented() -> CoreLogicExportsImpl {
        CoreLogicExportsImpl(favoritesService: FavoritesServiceUnimplemented())
    }

    /// Saved on the phone, with a versioned schema so later model changes migrate the store. If the store can't be
    /// opened, favorites are kept in memory so the app still works; they then last until the app closes.
    @Sendable static func makeFavoritesContainer() -> ModelContainer {
        let schema = Schema(versionedSchema: FavoritesSchemaV1.self)
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: FavoritesMigrationPlan.self,
                configurations: ModelConfiguration("Favorites", schema: schema)
            )
        } catch {
            Log.error("Favorites store could not be opened, using memory: \(type(of: error))", .favorites)
        }
        do {
            return try ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        } catch {
            fatalError("An in-memory SwiftData store could not be created: \(error)")
        }
    }
}
