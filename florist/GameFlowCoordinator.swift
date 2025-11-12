//
//  GameFlowCoordinator.swift
//  florist
//
//  Created by Reynaldo on 04/11/25.
//

import SwiftUI
import Combine

/// Coordinates the flow between different game pages
class GameFlowCoordinator: ObservableObject {
    enum GamePage: Hashable {
        case mainMenu
        case listening(storyId: String)
        case bouquet(storyId: String)
        case memories
        case options
    }
    
    @Published var navigationPath = NavigationPath()
    @Published var currentStoryId: String = "simple-encounter"
    
    // Story progression
    private var storyIndex: Int = 1
    private let totalStories: Int = 5 // Adjust based on your game
    
    // Progress restoration state
    private var savedProgress: StoryProgress?
    private var shouldRestoreProgress: Bool = false
    
    func navigateToListening(storyId: String) {
        currentStoryId = storyId
        navigationPath.append(GamePage.listening(storyId: storyId))
    }
    
    func navigateToBouquet(storyId: String) {
        navigationPath.append(GamePage.bouquet(storyId: storyId))
    }
    
    func navigateToMemories() {
        navigationPath.append(GamePage.memories)
    }
    
    func navigateToOptions() {
        navigationPath.append(GamePage.options)
    }
    
    func onBouquetComplete() {
        // Story completion is already marked when final scene is reached in StoryController
        // This method is called after the bouquet is successfully created
        
        // Move to next story
        storyIndex += 1
        
        if storyIndex <= totalStories {
            // For now, only using "simple-encounter"
            // Future use, use: let nextStoryId = "story_\(storyIndex)"
            let nextStoryId = "simple-encounter"
            navigateToListening(storyId: nextStoryId)
        } else {
            // All stories complete, return to main menu
            navigationPath.removeLast(navigationPath.count)
        }
    }
    
    func resetToMainMenu() {
        navigationPath.removeLast(navigationPath.count)
        storyIndex = 1
        currentStoryId = "simple-encounter"
    }
    
    func startNewGame() {
        storyIndex = 1
        currentStoryId = "simple-encounter"
        
        // Check for saved progress before starting
        Task {
            await checkForSavedProgress()
        }
    }
    
    // MARK: - Progress Restoration
    
    /// Checks for saved progress and restores if available
    @MainActor
    private func checkForSavedProgress() async {
        do {
            // Try to load progress for the current story
            if let progress = try await ProgressPersistenceManager.shared.loadProgress(for: currentStoryId) {
                // Store the progress for restoration
                savedProgress = progress
                shouldRestoreProgress = true
                
                print("✅ Found saved progress: Scene \(progress.currentSceneIndex)")
                
                // Navigate to listening page with restoration flag
                navigateToListening(storyId: currentStoryId)
            } else {
                // No saved progress, start from beginning
                print("ℹ️ No saved progress found, starting from beginning")
                navigateToListening(storyId: currentStoryId)
            }
        } catch {
            // If loading fails, start from beginning
            print("⚠️ Failed to check for saved progress: \(error.localizedDescription)")
            navigateToListening(storyId: currentStoryId)
        }
    }
    
    /// Returns the saved progress if available and clears the restoration flag
    /// - Returns: StoryProgress object if restoration is pending, nil otherwise
    @MainActor
    func getSavedProgressForRestoration() -> StoryProgress? {
        guard shouldRestoreProgress else { return nil }
        
        // Clear the flag and return the progress
        shouldRestoreProgress = false
        return savedProgress
    }
    
    /// Checks if there is saved progress for a specific story
    /// - Parameter storyId: The story identifier to check
    /// - Returns: True if progress exists, false otherwise
    func hasProgress(for storyId: String) async -> Bool {
        return await ProgressPersistenceManager.shared.hasProgress(for: storyId)
    }
    
    /// Switches to a different story, loading its saved progress if available
    /// - Parameter storyId: The story identifier to switch to
    func switchToStory(_ storyId: String) {
        currentStoryId = storyId
        
        // Check for saved progress for this story
        Task {
            await checkForSavedProgress()
        }
    }
    
    /// Gets all stories with saved progress
    /// - Returns: Array of story IDs that have saved progress
    func getStoriesWithProgress() async -> [String] {
        do {
            let allProgress = try await ProgressPersistenceManager.shared.getAllProgress()
            return allProgress.map { $0.storyId }
        } catch {
            print("⚠️ Failed to get stories with progress: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Validates that multiple story progress is working correctly
    func validateMultipleStoryProgress() async {
        do {
            let progressMap = try await ProgressPersistenceManager.shared.validateMultipleStoryProgress()
            print("📊 Active story progress:")
            for (storyId, sceneIndex) in progressMap.sorted(by: { $0.key < $1.key }) {
                print("  - \(storyId): Scene \(sceneIndex)")
            }
        } catch {
            print("⚠️ Failed to validate progress: \(error.localizedDescription)")
        }
    }
}
