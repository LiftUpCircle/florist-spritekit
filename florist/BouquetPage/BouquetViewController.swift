//
//  BouquetViewController.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import SwiftUI
import SpriteKit
import Combine

class BouquetViewController: ObservableObject {
    @Published var model = BouquetModel()
    @Published var isSettingsOpen = false
    private var gameScene: GameScene?
    private var onBouquetCompleteCallback: (() -> Void)?
    
    init(storyRequirements: StoryFlowerRequirements? = nil, onBouquetComplete: (() -> Void)? = nil) {
        self.onBouquetCompleteCallback = onBouquetComplete
        
        // Load story requirements
        if let requirements = storyRequirements {
            model.currentStoryRequirements = requirements
        } else {
            // Load default story for testing
            model.loadStoryRequirements(storyId: "story_default")
        }
    }

    func createGameScene(onBookTapped: @escaping () -> Void) -> GameScene {
        let scene = GameScene()
        scene.scaleMode = model.sceneScaleMode

        // Set story requirements
        if let requirements = model.currentStoryRequirements {
            scene.setStoryRequirements(requirements)
        }

        // Set callback for when bouquet is wrapped
        scene.onBouquetWrapped = { [weak self] result in
            self?.handleBouquetWrapped(result: result)
        }

        // Set callback for book button only (settings now handled internally)
        scene.onBookButtonTapped = onBookTapped

        // Set callback for settings state changes
        scene.onSettingsStateChanged = { [weak self] isOpen in
            DispatchQueue.main.async {
                self?.isSettingsOpen = isOpen
            }
        }

        gameScene = scene
        return scene
    }

    func updateSceneSize(_ size: CGSize) {
        model.updateSceneSize(size)
    }
    
    func loadStory(storyId: String) {
        model.loadStoryRequirements(storyId: storyId)
        
        // Update scene if already created
        if let scene = gameScene, let requirements = model.currentStoryRequirements {
            scene.setStoryRequirements(requirements)
        }
    }
    
    private func handleBouquetWrapped(result: StoryFlowerRequirements.ValidationResult) {
        // Handle the result
        switch result {
        case .perfectMatch:
            print("🎉 Perfect Match achieved!")
            // TODO: Save to memories, show letter
            // Proceed to next story
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.onBouquetCompleteCallback?()
            }
            
        case .goodMatch:
            print("👍 Good Match achieved!")
            // Proceed to next story
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.onBouquetCompleteCallback?()
            }
            
        case .failure(let message, let missingEmotions):
            print("❌ Validation failed: \(message)")
            print("Missing: \(missingEmotions.joined(separator: ", "))")
            // Player can try again
        }
    }
    
    func getCurrentBouquet() -> [Flower] {
        return gameScene?.getCurrentBouquet() ?? []
    }
}
