//
//  StoryController.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import Foundation
import Combine

/// Controller class that manages story state and coordinates between Model and View layers
class StoryController: ObservableObject {
    // MARK: - Published Properties (Observable State)
    
    /// The currently displayed scene
    @Published var currentScene: StoryScene?
    
    /// Index of the current scene in the story
    @Published var currentSceneIndex: Int = 0
    
    /// Flag indicating if the story has reached its end
    @Published var isStoryComplete: Bool = false
    
    /// Flag to control dialogue history sheet presentation
    @Published var showDialogueHistory: Bool = false
    
    /// Flag to control settings sheet presentation
    @Published var showSettings: Bool = false
    
    /// Array of all dialogue entries shown so far
    @Published var dialogueHistory: [DialogueEntry] = []
    
    /// Error message to display to the user
    @Published var errorMessage: String?
    
    /// Flag to control error alert presentation
    @Published var showError: Bool = false
    
    /// Flag indicating if typing animation is complete
    @Published var isTypingComplete: Bool = false
    
    /// Typing speed from settings
    @Published var typingSpeed: Double = 0.05
    
    /// Signal to complete typing immediately
    @Published var shouldCompleteTyping: Bool = false
    
    // MARK: - Private Properties
    
    private let storyManager = StoryManager.shared
    private let persistenceManager = ProgressPersistenceManager.shared
    private var storyData: StoryData?
    private var flowCoordinator: GameFlowCoordinator?
    
    // Use shared tracker to persist character appearances across story parts
    private let characterTracker = CharacterAppearanceTracker.shared
    
    // MARK: - Initialization
    
    init() {
        // Story will be loaded via loadStory(from:) when view appears
    }
    
    /// Sets the flow coordinator for progress restoration
    /// - Parameter coordinator: The GameFlowCoordinator instance
    func setFlowCoordinator(_ coordinator: GameFlowCoordinator) {
        self.flowCoordinator = coordinator
    }
    
    // MARK: - Public Methods

    /// Loads a story by its order key (e.g., "urutan1", "urutan2")
    /// - Parameter orderKey: The order key from the story index
    func loadStoryByOrder(_ orderKey: String) {
        do {
            storyData = try storyManager.loadStoryByOrder(orderKey)

            // Validate that we have at least one scene
            guard let firstScene = storyData?.scenes.first else {
                throw StoryLoadError.emptyStory
            }

            currentSceneIndex = 0
            currentScene = firstScene
            dialogueHistory = []
            isStoryComplete = false
            isTypingComplete = false
            
            // Mark first scene's character as appeared (if main character)
            characterTracker.markAsAppeared(characterName: firstScene.characterName)

            addToHistory(firstScene)

            // Check if there's saved progress to restore from the coordinator
            Task {
                await restoreProgressIfAvailable()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true

            // Set to empty state
            storyData = nil
            currentScene = nil
            dialogueHistory = []
            isStoryComplete = false
        }
    }

    /// Loads a story from a JSON file
    /// - Parameter filename: The name of the JSON file (without extension)
    func loadStory(from filename: String) {
        do {
            storyData = try storyManager.loadStory(from: filename)

            // Validate that we have at least one scene
            guard let firstScene = storyData?.scenes.first else {
                throw StoryLoadError.emptyStory
            }

            currentSceneIndex = 0
            currentScene = firstScene
            dialogueHistory = []
            isStoryComplete = false
            isTypingComplete = false
            
            // Mark first scene's character as appeared (if main character)
            characterTracker.markAsAppeared(characterName: firstScene.characterName)

            addToHistory(firstScene)

            // Check if there's saved progress to restore from the coordinator
            Task {
                await restoreProgressIfAvailable()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true

            // Set to empty state
            storyData = nil
            currentScene = nil
            dialogueHistory = []
            isStoryComplete = false
        }
    }
    
    /// Restores progress from the flow coordinator if available
    @MainActor
    private func restoreProgressIfAvailable() async {
        guard let storyData = storyData else { return }
        
        // First check if the coordinator has progress to restore
        if let coordinator = flowCoordinator,
           let savedProgress = coordinator.getSavedProgressForRestoration() {
            // Restore from coordinator's saved progress
            await restoreFromProgress(savedProgress)
        } else {
            // Fallback: try to load progress directly
            await loadSavedProgress(for: storyData.storyId)
        }
    }
    
    /// Restores the story state from a StoryProgress object
    /// - Parameter progress: The saved progress to restore from
    @MainActor
    private func restoreFromProgress(_ progress: StoryProgress) async {
        guard let storyData = storyData else {
            print("⚠️ Cannot restore progress: No story data loaded")
            return
        }
        
        // Validate that the saved scene index is within bounds
        guard progress.currentSceneIndex >= 0 else {
            print("❌ Saved scene index is negative (\(progress.currentSceneIndex)), starting from beginning")
            return
        }
        
        guard progress.currentSceneIndex < storyData.scenes.count else {
            print("❌ Saved scene index (\(progress.currentSceneIndex)) out of bounds (0..\(storyData.scenes.count)), starting from beginning")
            return
        }
        
        // Additional validation: check that dialogue history is reasonable
        guard progress.dialogueHistory.count <= 200 else {
            print("❌ Dialogue history too large (\(progress.dialogueHistory.count) entries), starting from beginning")
            return
        }
        
        // Restore the saved state
        currentSceneIndex = progress.currentSceneIndex
        currentScene = storyData.scenes[currentSceneIndex]
        
        // Restore dialogue history from persisted entries
        dialogueHistory = progress.dialogueHistory.map { historyEntry in
            DialogueEntry(
                id: UUID(),
                characterName: historyEntry.characterName,
                dialogue: historyEntry.dialogue,
                timestamp: historyEntry.timestamp
            )
        }
        
        // Mark all characters that have appeared up to the restored scene
        for i in 0...currentSceneIndex {
            let scene = storyData.scenes[i]
            characterTracker.markAsAppeared(characterName: scene.characterName)
        }
        
        isTypingComplete = false
        isStoryComplete = false
        
        print("✅ Restored progress for story '\(progress.storyId)': Scene \(progress.currentSceneIndex) with \(progress.dialogueHistory.count) dialogue entries")
    }
    
    /// Advances to the next scene in the story
    func advanceToNextScene() {
        guard let storyData = storyData else { return }
        guard !isStoryComplete else { return }
        guard isTypingComplete else { return }
        
        let nextSceneIndex = currentSceneIndex + 1
        
        if nextSceneIndex < storyData.scenes.count {
            let nextScene = storyData.scenes[nextSceneIndex]
            let characterName = nextScene.characterName
            
            // Proceed to next scene immediately
            performSceneChange(to: nextSceneIndex, in: storyData, scene: nextScene)
        } else {
            // Story is complete - mark it as such
            isStoryComplete = true
            
            // Mark story as complete in persistence
            Task {
                await markCurrentStoryComplete()
            }
        }
    }
    
    /// Performs the actual scene change
    private func performSceneChange(to sceneIndex: Int, in storyData: StoryData, scene: StoryScene) {
        currentSceneIndex = sceneIndex
        currentScene = scene
        isTypingComplete = false
        
        addToHistory(scene)
        
        // Save progress after advancing to next scene
        Task {
            await saveCurrentProgress()
        }
    }
    
    
    /// Called when typing animation completes
    func onTypingComplete() {
        isTypingComplete = true
    }
    
    /// Handles tap on dialogue - either completes typing or advances
    func handleDialogueTap() {
        if isTypingComplete {
            advanceToNextScene()
        }
    }
    
    /// Signals the dialogue box to complete typing immediately
    func completeCurrentTyping() {
        shouldCompleteTyping = true
        // Reset the flag after a brief moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.shouldCompleteTyping = false
        }
    }
    
    /// Resets the story to the beginning
    func resetStory() {
        currentSceneIndex = 0
        currentScene = storyData?.scenes.first
        dialogueHistory = []
        isStoryComplete = false
        isTypingComplete = false
        
        if let scene = currentScene {
            addToHistory(scene)
        }
    }
    
    /// Opens the dialogue history view
    func openDialogueHistory() {
        showDialogueHistory = true
    }
    
    /// Opens the settings view
    func openSettings() {
        showSettings = true
    }

    /// Skips the current story and marks it as complete
    func skipStory() {
        guard let storyData = storyData else { return }
        guard !isStoryComplete else { return }

        // Jump to the last scene index
        currentSceneIndex = storyData.scenes.count

        // Mark story as complete
        isStoryComplete = true

        // Mark story as complete in persistence
        Task {
            await markCurrentStoryComplete()
        }
    }

    // MARK: - Persistence Methods
    
    /// Saves the current story progress to persistent storage
    func saveCurrentProgress() async {
        guard let storyData = storyData else {
            print("⚠️ Cannot save progress: No story data loaded")
            return
        }
        
        let storyId = storyData.storyId
        
        // Validate scene index is within bounds before saving
        guard currentSceneIndex >= 0 && currentSceneIndex < storyData.scenes.count else {
            print("❌ Cannot save progress: Scene index \(currentSceneIndex) out of bounds (0..\(storyData.scenes.count))")
            return
        }
        
        do {
            try await persistenceManager.saveProgress(
                storyId: storyId,
                sceneIndex: currentSceneIndex,
                dialogueHistory: dialogueHistory
            )
        } catch {
            // Silent failure for auto-save - just log the error
            print("❌ Failed to save progress for story '\(storyId)': \(error.localizedDescription)")
        }
    }
    
    /// Loads saved progress for a specific story and restores the state
    /// - Parameter storyId: The unique identifier for the story
    func loadSavedProgress(for storyId: String) async {
        guard !storyId.isEmpty else {
            print("⚠️ Cannot load progress: Story ID is empty")
            return
        }
        
        guard let storyData = storyData else {
            print("⚠️ Cannot load progress: No story data loaded")
            return
        }
        
        do {
            // Try to load saved progress
            if let progress = try await persistenceManager.loadProgress(for: storyId) {
                // Validate that the saved scene index is within bounds
                guard progress.currentSceneIndex >= 0 else {
                    print("❌ Saved scene index is negative (\(progress.currentSceneIndex)), starting from beginning")
                    return
                }
                
                guard progress.currentSceneIndex < storyData.scenes.count else {
                    print("❌ Saved scene index (\(progress.currentSceneIndex)) out of bounds (0..\(storyData.scenes.count)), starting from beginning")
                    return
                }
                
                // Additional validation: check that dialogue history is reasonable
                guard progress.dialogueHistory.count <= 200 else {
                    print("❌ Dialogue history too large (\(progress.dialogueHistory.count) entries), starting from beginning")
                    return
                }
                
                // Restore the saved state on main actor
                await MainActor.run {
                    currentSceneIndex = progress.currentSceneIndex
                    currentScene = storyData.scenes[currentSceneIndex]
                    
                    // Restore dialogue history from persisted entries
                    dialogueHistory = progress.dialogueHistory.map { historyEntry in
                        DialogueEntry(
                            id: UUID(),
                            characterName: historyEntry.characterName,
                            dialogue: historyEntry.dialogue,
                            timestamp: historyEntry.timestamp
                        )
                    }
                    
                    // Mark all characters that have appeared up to the restored scene
                    for i in 0...currentSceneIndex {
                        let scene = storyData.scenes[i]
                        characterTracker.markAsAppeared(characterName: scene.characterName)
                    }
                    
                    isTypingComplete = false
                    isStoryComplete = false
                }
                
                print("✅ Restored progress for story '\(storyId)': Scene \(progress.currentSceneIndex) with \(progress.dialogueHistory.count) dialogue entries")
            } else {
                print("ℹ️ No saved progress found for story '\(storyId)', starting from beginning")
            }
        } catch {
            // If loading fails, just start from the beginning
            print("❌ Failed to load progress for story '\(storyId)': \(error.localizedDescription)")
            
            // Show error to user if it's a corrupted data error
            if let persistenceError = error as? ProgressPersistenceError,
               case .corruptedData = persistenceError {
                await MainActor.run {
                    errorMessage = "Your saved progress was corrupted and has been cleared. Starting from the beginning."
                    showError = true
                }
            }
        }
    }
    
    /// Clears saved progress for the current story
    func clearProgress() async {
        guard let storyData = storyData else { return }
        
        let storyId = storyData.storyId
        
        do {
            try await persistenceManager.deleteProgress(for: storyId)
            print("✅ Cleared progress for story: \(storyId)")
        } catch {
            print("⚠️ Failed to clear progress: \(error.localizedDescription)")
        }
    }
    
    /// Resets the current story progress and navigates to scene 0
    /// - Returns: Error message if reset fails, nil on success
    @MainActor
    func resetStoryProgress() async -> String? {
        guard let storyData = storyData else {
            return "No story loaded"
        }
        
        let storyId = storyData.storyId
        
        do {
            // Delete the progress record (preserves completion record)
            try await persistenceManager.deleteProgress(for: storyId)
            
            // Reset to scene 0
            currentSceneIndex = 0
            currentScene = storyData.scenes.first
            dialogueHistory = []
            isStoryComplete = false
            isTypingComplete = false
            
            if let scene = currentScene {
                addToHistory(scene)
            }
            
            print("✅ Reset story progress for: \(storyId)")
            return nil
        } catch {
            let errorMsg = "Failed to reset progress: \(error.localizedDescription)"
            print("⚠️ \(errorMsg)")
            return errorMsg
        }
    }
    
    /// Marks the current story as complete with archived dialogue history
    func markCurrentStoryComplete() async {
        guard let storyData = storyData else { return }
        
        let storyId = storyData.storyId
        let storyTitle = storyData.title
        
        do {
            try await persistenceManager.markStoryComplete(
                storyId: storyId,
                title: storyTitle,
                dialogueHistory: dialogueHistory
            )
            print("✅ Marked story complete: \(storyTitle)")
        } catch {
            print("⚠️ Failed to mark story complete: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Adds a scene's dialogue to the history
    /// - Parameter scene: The scene to add to history
    private func addToHistory(_ scene: StoryScene) {
        let entry = DialogueEntry(
            id: UUID(),
            characterName: scene.characterName,
            dialogue: scene.dialogue,
            timestamp: Date()
        )
        dialogueHistory.append(entry)
        
        // Limit history to 100 entries
        if dialogueHistory.count > 100 {
            dialogueHistory.removeFirst()
        }
    }
}
