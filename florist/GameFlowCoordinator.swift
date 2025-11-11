//
//  GameFlowCoordinator.swift
//  florist
//
//  Created by reynaldo on 04/11/25.
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
    @Published var currentStoryId: String = "story"
    
    // Story progression
    private var storyIndex: Int = 1
    private let totalStories: Int = 5 // Adjust based on your game
    
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
        // Move to next story
        storyIndex += 1
        
        if storyIndex <= totalStories {
            // For now, we only have one story file, so keep using "story"
            // In the future, use: let nextStoryId = "story_\(storyIndex)"
            let nextStoryId = "story"
            navigateToListening(storyId: nextStoryId)
        } else {
            // All stories complete, return to main menu
            navigationPath.removeLast(navigationPath.count)
        }
    }
    
    func resetToMainMenu() {
        navigationPath.removeLast(navigationPath.count)
        storyIndex = 1
    }
    
    func startNewGame() {
        storyIndex = 1
        currentStoryId = "story"
        navigateToListening(storyId: currentStoryId)
    }
}
