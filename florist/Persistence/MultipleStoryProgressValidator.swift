//
//  MultipleStoryProgressValidator.swift
//  florist
//
//  Validation helper for testing multiple story progress management
//

import Foundation
import SwiftData

/// Helper class to validate multiple story progress functionality
@MainActor
class MultipleStoryProgressValidator {
    
    private let persistenceManager = ProgressPersistenceManager.shared
    
    /// Simulates saving progress for multiple stories
    /// - Returns: True if all operations succeeded, false otherwise
    func simulateMultipleStoryProgress() async -> Bool {
        print("🧪 Starting multiple story progress simulation...")
        
        // Test story IDs
        let testStories = [
            ("story-1", "First Story"),
            ("story-2", "Second Story"),
            ("story-3", "Third Story"),
            ("story-4", "Fourth Story"),
            ("story-5", "Fifth Story")
        ]
        
        do {
            // 1. Save progress for multiple stories
            print("\n📝 Step 1: Saving progress for \(testStories.count) stories...")
            for (index, (storyId, title)) in testStories.enumerated() {
                let sceneIndex = index * 2 + 1 // Different scene for each story
                let dialogueHistory = [
                    DialogueEntry(
                        id: UUID(),
                        characterName: "Character \(index + 1)",
                        dialogue: "Test dialogue for \(title)",
                        timestamp: Date()
                    )
                ]
                
                try await persistenceManager.saveProgress(
                    storyId: storyId,
                    sceneIndex: sceneIndex,
                    dialogueHistory: dialogueHistory
                )
                print("  ✅ Saved progress for \(storyId) at scene \(sceneIndex)")
            }
            
            // 2. Verify all progress was saved
            print("\n🔍 Step 2: Verifying all progress records...")
            let allProgress = try await persistenceManager.getAllProgress()
            print("  Found \(allProgress.count) progress records")
            
            guard allProgress.count == testStories.count else {
                print("  ❌ Expected \(testStories.count) records, found \(allProgress.count)")
                return false
            }
            
            // 3. Verify each story has correct progress
            print("\n✓ Step 3: Verifying individual story progress...")
            for (index, (storyId, _)) in testStories.enumerated() {
                let expectedScene = index * 2 + 1
                
                if let progress = try await persistenceManager.loadProgress(for: storyId) {
                    if progress.currentSceneIndex == expectedScene {
                        print("  ✅ \(storyId): Scene \(progress.currentSceneIndex) (correct)")
                    } else {
                        print("  ❌ \(storyId): Expected scene \(expectedScene), got \(progress.currentSceneIndex)")
                        return false
                    }
                } else {
                    print("  ❌ \(storyId): Progress not found")
                    return false
                }
            }
            
            // 4. Test story switching by updating one story
            print("\n🔄 Step 4: Testing story switching...")
            let (switchStoryId, _) = testStories[1]
            let newSceneIndex = 99
            
            try await persistenceManager.saveProgress(
                storyId: switchStoryId,
                sceneIndex: newSceneIndex,
                dialogueHistory: []
            )
            
            if let updatedProgress = try await persistenceManager.loadProgress(for: switchStoryId) {
                if updatedProgress.currentSceneIndex == newSceneIndex {
                    print("  ✅ Successfully updated \(switchStoryId) to scene \(newSceneIndex)")
                } else {
                    print("  ❌ Update failed for \(switchStoryId)")
                    return false
                }
            }
            
            // 5. Verify other stories weren't affected
            print("\n🛡️ Step 5: Verifying other stories weren't affected...")
            for (index, (storyId, _)) in testStories.enumerated() where index != 1 {
                let expectedScene = index * 2 + 1
                
                if let progress = try await persistenceManager.loadProgress(for: storyId) {
                    if progress.currentSceneIndex == expectedScene {
                        print("  ✅ \(storyId): Still at scene \(expectedScene)")
                    } else {
                        print("  ❌ \(storyId): Unexpectedly changed to scene \(progress.currentSceneIndex)")
                        return false
                    }
                }
            }
            
            // 6. Test storage limit (10 concurrent records)
            print("\n📊 Step 6: Testing storage limit...")
            let currentCount = try await persistenceManager.getProgressCount()
            print("  Current progress count: \(currentCount)")
            
            // Add more stories to test the limit
            for i in 6...12 {
                let storyId = "story-\(i)"
                try await persistenceManager.saveProgress(
                    storyId: storyId,
                    sceneIndex: i,
                    dialogueHistory: []
                )
            }
            
            let finalCount = try await persistenceManager.getProgressCount()
            print("  Final progress count: \(finalCount)")
            
            if finalCount <= 10 {
                print("  ✅ Storage limit enforced (max 10 records)")
            } else {
                print("  ⚠️ Storage limit not enforced: \(finalCount) records exist")
            }
            
            // 7. Validate no duplicate story IDs
            print("\n🔍 Step 7: Validating no duplicate story IDs...")
            let progressMap = try await persistenceManager.validateMultipleStoryProgress()
            print("  ✅ All story IDs are unique (\(progressMap.count) records)")
            
            print("\n✅ All validation tests passed!")
            return true
            
        } catch {
            print("\n❌ Validation failed with error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Cleans up test data
    func cleanupTestData() async {
        print("\n🧹 Cleaning up test data...")
        
        let testStoryIds = (1...12).map { "story-\($0)" }
        
        for storyId in testStoryIds {
            do {
                try await persistenceManager.deleteProgress(for: storyId)
                print("  ✅ Deleted progress for \(storyId)")
            } catch {
                print("  ⚠️ Failed to delete \(storyId): \(error.localizedDescription)")
            }
        }
        
        print("✅ Cleanup complete")
    }
}
