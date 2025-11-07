//
//  BouquetModel.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import Foundation
import SpriteKit

struct BouquetModel {
    var sceneSize: CGSize = .zero
    var sceneScaleMode: SKSceneScaleMode = .resizeFill
    
    // Bouquet state
    var currentBouquet: [Flower] = []
    var maxBouquetSize: Int = 6
    
    // Story requirements (will be set from listening page)
    var currentStoryRequirements: StoryFlowerRequirements?
    var currentStoryId: String = "story_default" // Default for testing
    
    // UI State
    var canWrap: Bool {
        return !currentBouquet.isEmpty
    }
    
    var canReset: Bool {
        return !currentBouquet.isEmpty
    }

    mutating func updateSceneSize(_ size: CGSize) {
        self.sceneSize = size
    }
    
    mutating func addFlowerToBouquet(_ flower: Flower) -> Bool {
        guard currentBouquet.count < maxBouquetSize else { return false }
        currentBouquet.append(flower)
        return true
    }
    
    mutating func removeFlowerFromBouquet(at index: Int) -> Flower? {
        guard index >= 0 && index < currentBouquet.count else { return nil }
        return currentBouquet.remove(at: index)
    }
    
    mutating func resetBouquet() {
        currentBouquet.removeAll()
    }
    
    func validateBouquet() -> StoryFlowerRequirements.ValidationResult {
        guard let requirements = currentStoryRequirements else {
            // If no requirements set, use default
            let defaultRequirements = StoryRequirementsDatabase.shared.getRequirements(for: currentStoryId)!
            return defaultRequirements.validate(bouquet: currentBouquet)
        }
        return requirements.validate(bouquet: currentBouquet)
    }
    
    mutating func loadStoryRequirements(storyId: String) {
        self.currentStoryId = storyId
        self.currentStoryRequirements = StoryRequirementsDatabase.shared.getRequirements(for: storyId)
    }
}
