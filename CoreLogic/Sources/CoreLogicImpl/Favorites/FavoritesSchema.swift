//
//  FavoritesSchema.swift
//  CoreLogicImpl
//

import SwiftData

/// The favorites store's first schema. A later model change adds `FavoritesSchemaV2` and a migration stage, so stores
/// already on phones are moved over instead of failing to open.
enum FavoritesSchemaV1: VersionedSchema {

    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [FavoriteImageRecord.self]
    }
}

/// Every schema the store has had, oldest first, and how to move between them.
enum FavoritesMigrationPlan: SchemaMigrationPlan {

    static var schemas: [any VersionedSchema.Type] {
        [FavoritesSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
