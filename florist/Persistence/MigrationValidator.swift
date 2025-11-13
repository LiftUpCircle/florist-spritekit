//
//  MigrationValidator.swift
//  florist
//
//  Utility for testing SwiftData schema migrations with sample data
//

import Foundation
import SwiftData

/// Validator for testing schema migrations
@MainActor
final class MigrationValidator {
    
    /// Tests migration by creating sample data and verifying it persists correctly
    static func validateMigration() async -> Bool {
        print("🧪 Starting migration validation...")
        
        do {
            // Create a temporary in-memory container for testing
            let configuration = ModelConfiguration(
                schema: Schema(versionedSchema: SchemaV1.self),
                isStoredInMemoryOnly: true
            )
            
            let container = try ModelContainer(
                for: StoryProgress.self,
                CompletedStory.self,
                DialogueHistoryEntry.self,
                migrationPlan: AppSchemaMigrationPlan.self,
                configurations: configuration
            )
            
            let context = ModelContext(container)
            
            // Create sample data
            let sampleDialogue = DialogueHistoryEntry(
                characterName: "Test Character",
                dialogue: "Test dialogue for migration validation",
                timestamp: Date(),
                sceneId: "scene_0"
            )
            
            let sampleProgress = StoryProgress(
                storyId: "test_story_migration",
                currentSceneIndex: 5,
                lastPlayedDate: Date(),
                dialogueHistory: [sampleDialogue]
            )
            
            let sampleCompleted = CompletedStory(
                storyId: "completed_test_story",
                completionDate: Date(),
                storyTitle: "Test Story",
                archivedDialogueHistory: [sampleDialogue]
            )
            
            // Insert sample data
            context.insert(sampleProgress)
            context.insert(sampleCompleted)
            
            try context.save()
            print("✅ Sample data created successfully")
            
            // Verify data can be retrieved
            let fetchDescriptor = FetchDescriptor<StoryProgress>(
                predicate: #Predicate { $0.storyId == "test_story_migration" }
            )
            
            let results = try context.fetch(fetchDescriptor)
            
            guard let retrievedProgress = results.first else {
                print("❌ Failed to retrieve sample data")
                return false
            }
            
            // Validate data integrity
            let isValid = retrievedProgress.storyId == "test_story_migration" &&
                         retrievedProgress.currentSceneIndex == 5 &&
                         retrievedProgress.dialogueHistory.count == 1
            
            if isValid {
                print("✅ Migration validation successful - data integrity confirmed")
            } else {
                print("❌ Migration validation failed - data integrity check failed")
            }
            
            return isValid
            
        } catch {
            print("❌ Migration validation failed with error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Validates that the current schema version matches expectations
    static func validateSchemaVersion() -> Bool {
        let currentVersion = SchemaVersion.current
        let expectedVersion = SchemaVersion.v1
        
        let isValid = currentVersion == expectedVersion
        
        if isValid {
            print("✅ Schema version validation successful: v\(currentVersion.rawValue)")
        } else {
            print("❌ Schema version mismatch: expected v\(expectedVersion.rawValue), got v\(currentVersion.rawValue)")
        }
        
        return isValid
    }
    
    /// Comprehensive validation that runs all checks
    static func runFullValidation() async -> Bool {
        print("🔍 Running comprehensive migration validation...")
        
        let schemaValid = validateSchemaVersion()
        let migrationValid = await validateMigration()
        
        let allValid = schemaValid && migrationValid
        
        if allValid {
            print("✅ All migration validations passed")
        } else {
            print("❌ Some migration validations failed")
        }
        
        return allValid
    }
}
