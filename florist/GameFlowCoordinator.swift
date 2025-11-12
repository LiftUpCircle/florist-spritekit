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
        case storyComplete(storyId: String) // New: show completion dialog
    }

    @Published var navigationPath = NavigationPath()
    @Published var showCompletionDialog = false
    @Published var currentCompletedStoryId: String?

    private let progressManager = GameProgressManager.shared

    var currentStoryId: String {
        progressManager.currentStoryId
    }

    func navigateToListening(storyId: String) {
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

    // Called when bouquet is successfully wrapped
    func onBouquetComplete() {
        let completedStoryId = currentStoryId

        // Mark story as complete
        progressManager.completeCurrentStory()

        // Show completion dialog
        currentCompletedStoryId = completedStoryId
        showCompletionDialog = true
    }

    // User chooses to continue to next story
    func continueToNextStory() {
        showCompletionDialog = false

        if progressManager.hasMoreStories {
            // Move to next story
            progressManager.moveToNextStory()
            navigateToListening(storyId: currentStoryId)
        } else {
            // All stories complete, return to main menu
            showAllStoriesCompleteDialog()
        }
    }

    // User chooses to return to main menu
    func returnToMainMenu() {
        showCompletionDialog = false
        navigationPath.removeLast(navigationPath.count)
    }

    private func showAllStoriesCompleteDialog() {
        // TODO: Show a special "All stories complete!" dialog
        print("🎉 All stories completed!")
        returnToMainMenu()
    }

    func resetToMainMenu() {
        showCompletionDialog = false
        navigationPath.removeLast(navigationPath.count)
    }

    func startNewGame() {
        progressManager.resetToFirstStory()
        navigateToListening(storyId: currentStoryId)
    }

    func continueGame() {
        // Continue from current story
        navigateToListening(storyId: currentStoryId)
    }
}
