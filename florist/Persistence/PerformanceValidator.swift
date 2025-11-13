//
//  PerformanceValidator.swift
//  florist
//
//  Performance validation utility for persistence operations
//

import Foundation

/// Utility for validating persistence performance against requirements
@MainActor
class PerformanceValidator {
    
    private let persistenceManager = ProgressPersistenceManager.shared
    
    // Performance targets from requirements
    private let targetSaveLatency: TimeInterval = 0.5 // 500ms
    private let targetLoadLatency: TimeInterval = 1.0 // 1s
    
    /// Validates save operation performance
    /// - Parameters:
    ///   - storyId: Story ID to test with
    ///   - sceneIndex: Scene index to test with
    ///   - dialogueHistory: Dialogue history to test with
    /// - Returns: True if performance meets requirements, false otherwise
    func validateSavePerformance(storyId: String, sceneIndex: Int, dialogueHistory: [DialogueEntry]) async -> Bool {
        print("🧪 Testing save operation performance...")
        
        do {
            // Perform save operation
            try await persistenceManager.saveProgress(
                storyId: storyId,
                sceneIndex: sceneIndex,
                dialogueHistory: dialogueHistory
            )
            
            // Check latency
            let latency = persistenceManager.getLastSaveLatency()
            let latencyMs = latency * 1000
            let meetsTarget = latency <= targetSaveLatency
            
            if meetsTarget {
                print("✅ Save performance test PASSED: \(String(format: "%.0f", latencyMs))ms (target: \(String(format: "%.0f", targetSaveLatency * 1000))ms)")
            } else {
                print("❌ Save performance test FAILED: \(String(format: "%.0f", latencyMs))ms exceeds target of \(String(format: "%.0f", targetSaveLatency * 1000))ms")
            }
            
            return meetsTarget
        } catch {
            print("❌ Save performance test FAILED with error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Validates load operation performance
    /// - Parameter storyId: Story ID to test with
    /// - Returns: True if performance meets requirements, false otherwise
    func validateLoadPerformance(storyId: String) async -> Bool {
        print("🧪 Testing load operation performance...")
        
        do {
            // Perform load operation
            _ = try await persistenceManager.loadProgress(for: storyId)
            
            // Check latency
            let latency = persistenceManager.getLastLoadLatency()
            let latencyMs = latency * 1000
            let meetsTarget = latency <= targetLoadLatency
            
            if meetsTarget {
                print("✅ Load performance test PASSED: \(String(format: "%.0f", latencyMs))ms (target: \(String(format: "%.0f", targetLoadLatency * 1000))ms)")
            } else {
                print("❌ Load performance test FAILED: \(String(format: "%.0f", latencyMs))ms exceeds target of \(String(format: "%.0f", targetLoadLatency * 1000))ms")
            }
            
            return meetsTarget
        } catch {
            print("❌ Load performance test FAILED with error: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Runs a comprehensive performance test suite
    /// - Returns: True if all tests pass, false otherwise
    func runPerformanceTests() async -> Bool {
        print("🧪 ===== Starting Performance Test Suite =====")
        
        // Create test data
        let testStoryId = "performance_test_story"
        let testSceneIndex = 5
        let testDialogueHistory = createTestDialogueHistory(count: 50)
        
        var allTestsPassed = true
        
        // Test 1: Save performance
        let saveTestPassed = await validateSavePerformance(
            storyId: testStoryId,
            sceneIndex: testSceneIndex,
            dialogueHistory: testDialogueHistory
        )
        allTestsPassed = allTestsPassed && saveTestPassed
        
        // Test 2: Load performance
        let loadTestPassed = await validateLoadPerformance(storyId: testStoryId)
        allTestsPassed = allTestsPassed && loadTestPassed
        
        // Test 3: Multiple rapid saves (debouncing test)
        print("🧪 Testing debouncing with rapid saves...")
        let debounceTestPassed = await testDebouncing(storyId: testStoryId)
        allTestsPassed = allTestsPassed && debounceTestPassed
        
        // Test 4: Large dialogue history
        print("🧪 Testing with large dialogue history...")
        let largeDataTestPassed = await testLargeDataPerformance(storyId: testStoryId)
        allTestsPassed = allTestsPassed && largeDataTestPassed
        
        // Clean up test data
        do {
            try await persistenceManager.deleteProgress(for: testStoryId)
            print("🧹 Cleaned up test data")
        } catch {
            print("⚠️ Failed to clean up test data: \(error.localizedDescription)")
        }
        
        // Print summary
        print("🧪 ===== Performance Test Suite Complete =====")
        if allTestsPassed {
            print("✅ ALL TESTS PASSED")
        } else {
            print("❌ SOME TESTS FAILED")
        }
        
        // Log performance stats
        persistenceManager.logPerformanceStats()
        
        return allTestsPassed
    }
    
    /// Tests debouncing behavior with rapid saves
    private func testDebouncing(storyId: String) async -> Bool {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Trigger 5 rapid saves
        for i in 0..<5 {
            let dialogueHistory = createTestDialogueHistory(count: 10)
            do {
                try await persistenceManager.saveProgress(
                    storyId: storyId,
                    sceneIndex: i,
                    dialogueHistory: dialogueHistory
                )
            } catch {
                print("❌ Debounce test failed: \(error.localizedDescription)")
                return false
            }
        }
        
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // With debouncing, this should complete quickly (not 5x save time)
        // The actual saves are batched, so total time should be reasonable
        let passed = totalTime < 5.0 // Should complete in under 5 seconds
        
        if passed {
            print("✅ Debouncing test PASSED: \(String(format: "%.2f", totalTime))s for 5 rapid saves")
        } else {
            print("❌ Debouncing test FAILED: \(String(format: "%.2f", totalTime))s (too slow)")
        }
        
        return passed
    }
    
    /// Tests performance with large dialogue history
    private func testLargeDataPerformance(storyId: String) async -> Bool {
        // Create large dialogue history (100 entries - the max)
        let largeDialogueHistory = createTestDialogueHistory(count: 100)
        
        let saveTestPassed = await validateSavePerformance(
            storyId: storyId,
            sceneIndex: 10,
            dialogueHistory: largeDialogueHistory
        )
        
        if !saveTestPassed {
            return false
        }
        
        let loadTestPassed = await validateLoadPerformance(storyId: storyId)
        
        return loadTestPassed
    }
    
    /// Creates test dialogue history
    private func createTestDialogueHistory(count: Int) -> [DialogueEntry] {
        var history: [DialogueEntry] = []
        
        for i in 0..<count {
            let entry = DialogueEntry(
                id: UUID(),
                characterName: "Test Character \(i % 3)",
                dialogue: "This is test dialogue entry number \(i). It contains some sample text to simulate real dialogue content.",
                timestamp: Date()
            )
            history.append(entry)
        }
        
        return history
    }
}
