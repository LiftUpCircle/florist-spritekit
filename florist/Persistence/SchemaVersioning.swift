//
//  SchemaVersioning.swift
//  florist
//
//  SwiftData schema versioning and migration logic
//

import Foundation
import SwiftData

/// Schema version enumeration for tracking data model versions
enum SchemaVersion: Int, CaseIterable {
    case v1 = 1
    
    /// Returns the current schema version
    static var current: SchemaVersion {
        return .v1
    }
    
    /// Returns all schema versions in order
    static var allVersions: [SchemaVersion] {
        return SchemaVersion.allCases
    }
}

/// Schema V1: Initial schema with StoryProgress, CompletedStory, and DialogueHistoryEntry
enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [StoryProgress.self, CompletedStory.self, DialogueHistoryEntry.self]
    }
}

/// Migration plan for handling schema version transitions
struct AppSchemaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        // Future migration stages will be added here
        // Example for V1 to V2 migration:
        // [migrateV1toV2]
        []
    }
    
    // Example migration stage (for future use):
    // static let migrateV1toV2 = MigrationStage.custom(
    //     fromVersion: SchemaV1.self,
    //     toVersion: SchemaV2.self,
    //     willMigrate: { context in
    //         // Pre-migration logic
    //     },
    //     didMigrate: { context in
    //         // Post-migration logic
    //     }
    // )
}
