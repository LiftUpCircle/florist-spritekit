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
    private var gameScene: GameScene?
    
    init() {
        // Load default story for testing
        model.loadStoryRequirements(storyId: "story_default")
    }

    func createGameScene() -> GameScene {
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
            // TODO: Save to memories, show letter, proceed to next story
            
        case .goodMatch:
            print("👍 Good Match achieved!")
            // TODO: Proceed to next story
            
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
