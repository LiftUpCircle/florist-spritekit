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
        case storyComplete(storyId: String) // New: show completion dialog
    }

    @Published var navigationPath = NavigationPath()
    @Published var showBouquetSavedToast = false
    @Published var toastMessage = ""
    @Published var showLoadingScreen = false

    private let progressManager = GameProgressManager.shared

    // Progress restoration state
    private var savedProgress: StoryProgress?
    private var shouldRestoreProgress: Bool = false

    var currentStoryId: String {
        progressManager.currentStoryId
    }


    func navigateToListening(storyId: String) {
        navigationPath.append(GamePage.listening(storyId: storyId))
    }

    func navigateToBouquet(storyId: String) {
        print("🔄 navigateToBouquet called for storyId: \(storyId)")

        // Show loading screen with animation
        withAnimation(.easeIn(duration: 0.3)) {
            showLoadingScreen = true
            print("✅ Loading screen set to true")
        }

        // Wait for loading screen to be fully visible, then navigate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            print("⏱️ Navigating to bouquet page...")
            self?.navigationPath.append(GamePage.bouquet(storyId: storyId))

            // Hide loading screen after navigation and view loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    self?.showLoadingScreen = false
                    print("❌ Loading screen set to false")
                }
            }
        }
    }

    func navigateToMemories() {
        navigationPath.append(GamePage.memories)
    }

    func navigateToOptions() {
        navigationPath.append(GamePage.options)
    }

    // Called when a story completes without needing a bouquet (e.g., prologue, second parts)
    func onStoryCompleteNoBouquet(for storyId: String? = nil) {
        let completedStory = storyId ?? currentStoryId

        // Check if this is a second part story
        do {
            let storyIndex = try StoryManager.shared.loadStoryIndex()
            if let story = storyIndex.stories[completedStory],
               story.isSecondPart == true {
                // This is a second part - now mark the main story as complete and continue
                progressManager.completeCurrentStory()

                // Continue to next story
                if progressManager.hasMoreStories {
                    progressManager.moveToNextStory()
                    navigateToListening(storyId: currentStoryId)
                } else {
                    // All stories complete, return to main menu
                    print("🎉 All stories completed!")
                    returnToMainMenu()
                }
            } else {
                // Normal story without bouquet (like prologue)
                progressManager.completeCurrentStory()

                // Continue to next story
                if progressManager.hasMoreStories {
                    progressManager.moveToNextStory()
                    navigateToListening(storyId: currentStoryId)
                } else {
                    // All stories complete, return to main menu
                    print("🎉 All stories completed!")
                    returnToMainMenu()
                }
            }
        } catch {
            print("⚠️ Failed to check story type: \(error)")
            // Default behavior
            progressManager.completeCurrentStory()

            if progressManager.hasMoreStories {
                progressManager.moveToNextStory()
                navigateToListening(storyId: currentStoryId)
            } else {
                print("🎉 All stories completed!")
                returnToMainMenu()
            }
        }
    }

    // Called when bouquet is successfully wrapped
    // The storyId parameter is passed from the BouquetPageWrapper
    func onBouquetComplete(for storyId: String? = nil) {
        let currentStory = storyId ?? currentStoryId

        // Check if current story has a second part
        do {
            let storyIndex = try StoryManager.shared.loadStoryIndex()
            if let story = storyIndex.stories[currentStory],
               story.hasSecondPart == true,
               let secondPartId = story.secondPartId {

                // DON'T mark story complete yet - it has a second part!
                // Get character name from story ID
                let characterName = getCharacterName(from: currentStory)

                // Show toast notification
                toastMessage = "Bouquet for \(characterName) saved to memories!"
                showBouquetSavedToast = true

                // Navigate to second part of the story after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    print("📖 Navigating to second part: \(secondPartId)")
                    self?.navigateToListening(storyId: secondPartId)
                }
            } else {
                // No second part, proceed normally
                progressManager.completeCurrentStory()

                // Get character name from story ID
                let characterName = getCharacterName(from: currentStory)

                // Show toast notification
                toastMessage = "Bouquet for \(characterName) saved to memories!"
                showBouquetSavedToast = true

                // Automatically continue to next story after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.continueToNextStory()
                }
            }
        } catch {
            print("⚠️ Failed to check for second part: \(error)")
            // Default behavior
            progressManager.completeCurrentStory()

            let characterName = getCharacterName(from: currentStory)
            toastMessage = "Bouquet for \(characterName) saved to memories!"
            showBouquetSavedToast = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.continueToNextStory()
            }
        }
    }

    // Automatically continue to next story
    private func continueToNextStory() {
        if progressManager.hasMoreStories {
            print("🔄 continueToNextStory called")

            // Show loading screen with animation
            withAnimation(.easeIn(duration: 0.3)) {
                showLoadingScreen = true
                print("✅ Loading screen set to true for next story")
            }

            // Move to next story
            progressManager.moveToNextStory()

            // Wait for loading screen to be fully visible, then navigate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                print("⏱️ Navigating to next listening page...")
                self.navigationPath.append(GamePage.listening(storyId: self.currentStoryId))

                // Hide loading screen after navigation and view loads
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.showLoadingScreen = false
                        print("❌ Loading screen set to false after next story")
                    }
                }
            }
        } else {
            // All stories complete, return to main menu
            print("🎉 All stories completed!")
            returnToMainMenu()
        }
    }

    // Return to main menu
    func returnToMainMenu() {
        navigationPath.removeLast(navigationPath.count)
    }

    func resetToMainMenu() {
        navigationPath.removeLast(navigationPath.count)
    }

    // Helper to get character name from story ID
    private func getCharacterName(from storyId: String) -> String {
        // Load story index to get character name
        do {
            let storyIndex = try StoryManager.shared.loadStoryIndex()
            if let storyEntry = storyIndex.stories[storyId] {
                // Extract first name from full character name
                let fullName = storyEntry.characterName
                let firstName = fullName.split(separator: " ").first.map(String.init) ?? fullName
                return firstName
            }
        } catch {
            print("⚠️ Failed to load story index for character name: \(error)")
        }

//        // Fallback for old story IDs or when loading fails
//        if storyId.contains("robert") {
//            return "Robert"
//        } else if storyId.contains("abigail") {
//            return "Abigail"
//        } else if storyId.contains("michael") {
//            return "Michael"
//        }

        return "this character"
    }

    func startNewGame() {
        // Don't reset to first story - continue from where the player was
        // The GameProgressManager already loads the saved story index on init

        // Check for saved progress before starting
        Task {
            await checkForSavedProgress()
        }
    }

    func resetAndStartNewGame() {
        // This actually resets to the first story (for when user explicitly wants new game)
        progressManager.resetToFirstStory()

        // Check for saved progress before starting
        Task {
            await checkForSavedProgress()
        }
    }

    func continueGame() {
        // Continue from current story
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
        // This would need to integrate with GameProgressManager if we want to
        // support switching stories outside the normal progression
        // For now, just check for saved progress
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
