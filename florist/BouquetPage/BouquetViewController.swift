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
    private var onBouquetCompleteCallback: (() -> Void)?
    private var currentStoryId: String?

    init(storyRequirements: StoryFlowerRequirements? = nil, storyId: String? = nil, onBouquetComplete: (() -> Void)? = nil) {
        self.onBouquetCompleteCallback = onBouquetComplete
        self.currentStoryId = storyId

        // Load story requirements
        if let requirements = storyRequirements {
            model.currentStoryRequirements = requirements
        } else if let storyId = storyId {
            model.loadStoryRequirements(storyId: storyId)
        } else {
            // Load default story for testing
            model.loadStoryRequirements(storyId: "story_default")
            self.currentStoryId = "story_default"
        }
    }

    func createGameScene(onBookTapped: @escaping () -> Void) -> GameScene {
        let scene = GameScene()
        scene.scaleMode = model.sceneScaleMode

        // Set story requirements
        if let requirements = model.currentStoryRequirements {
            scene.setStoryRequirements(requirements)
        }

        // Set story ID
        scene.currentStoryId = currentStoryId

        // Set callback for when bouquet is wrapped
        scene.onBouquetWrapped = { [weak self] result in
            self?.handleBouquetWrapped(result: result)
        }

        // Set callback for bouquet completion (save to memories)
        scene.onBouquetCompleted = { [weak self] image, storyId in
            self?.saveBouquetToMemories(image: image, storyId: storyId)
        }

        // Set callback for book button only (settings now handled internally)
        scene.onBookButtonTapped = onBookTapped

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
            // Proceed to next story after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.onBouquetCompleteCallback?()
            }

        case .goodMatch:
            print("👍 Good Match achieved!")
            // Proceed to next story after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.onBouquetCompleteCallback?()
            }

        case .failure(let message, let missingEmotions):
            print("❌ Validation failed: \(message)")
            print("Missing: \(missingEmotions.joined(separator: ", "))")
            // Player can try again
        }
    }

    private func saveBouquetToMemories(image: UIImage, storyId: String) {
        let success = MemoriesManager.shared.saveBouquet(image: image, storyId: storyId)
        if success {
            print("✅ BouquetViewController: Bouquet saved to memories for story: \(storyId)")
        } else {
            print("❌ BouquetViewController: Failed to save bouquet for story: \(storyId)")
        }
    }
    
    func getCurrentBouquet() -> [Flower] {
        return gameScene?.getCurrentBouquet() ?? []
    }
}
