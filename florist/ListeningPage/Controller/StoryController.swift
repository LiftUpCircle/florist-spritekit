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
    private var storyData: StoryData?
    
    // MARK: - Initialization
    
    init() {
        loadStory(from: "story")
    }
    
    // MARK: - Public Methods
    
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
            
            addToHistory(firstScene)
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
    
    /// Advances to the next scene in the story
    func advanceToNextScene() {
        guard let storyData = storyData else { return }
        guard !isStoryComplete else { return }
        guard isTypingComplete else { return }
        
        currentSceneIndex += 1
        isTypingComplete = false
        
        if currentSceneIndex < storyData.scenes.count {
            currentScene = storyData.scenes[currentSceneIndex]
            if let scene = currentScene {
                addToHistory(scene)
            }
        } else {
            isStoryComplete = true
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
