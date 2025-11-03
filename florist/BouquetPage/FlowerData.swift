//
//  FlowerData.swift
//  florist
//
//  Created by reynaldo on 03/11/25.
//

import Foundation
import UIKit

// MARK: - Flower Data Models

struct Flower: Identifiable, Equatable {
    let id: UUID = UUID()
    let flowerId: Int
    let flowerName: String
    let flowerColor: UIColor
    let emotion: String // e.g., "Fondness", "Joy", "Sadness"
    
    static func == (lhs: Flower, rhs: Flower) -> Bool {
        return lhs.flowerId == rhs.flowerId
    }
}

struct FlowerRequirement {
    let emotion: String // The emotion/event needed
    let minimumCount: Int // Minimum flowers needed for "Match"
    let idealCount: Int // Ideal flowers needed for "Perfect Match"
    let flower: Flower // The required flower type
}

struct StoryFlowerRequirements {
    let storyId: String
    let requirements: [FlowerRequirement]
    let maxBouquetSize: Int = 6
    let hintText: String // Short sentence with highlighted words
    
    // Check if bouquet satisfies requirements
    func validate(bouquet: [Flower]) -> ValidationResult {
        var satisfiedRequirements: [String: Int] = [:]
        var perfectMatches: [String: Bool] = [:]
        
        // Count flowers by emotion
        for flower in bouquet {
            satisfiedRequirements[flower.emotion, default: 0] += 1
        }
        
        var allMatch = true
        var allPerfect = true
        var missingEmotions: [String] = []
        
        for requirement in requirements {
            let count = satisfiedRequirements[requirement.emotion] ?? 0
            
            if count < requirement.minimumCount {
                allMatch = false
                allPerfect = false
                missingEmotions.append(requirement.emotion)
            } else if count < requirement.idealCount {
                allPerfect = false
                perfectMatches[requirement.emotion] = false
            } else {
                perfectMatches[requirement.emotion] = true
            }
        }
        
        if !allMatch {
            return .failure(message: "Hmm, something's missing...", missingEmotions: missingEmotions)
        } else if allPerfect {
            return .perfectMatch
        } else {
            return .goodMatch
        }
    }
    
    enum ValidationResult {
        case perfectMatch
        case goodMatch
        case failure(message: String, missingEmotions: [String])
    }
}

// MARK: - Sample Flowers Database

class FlowerDatabase {
    static let shared = FlowerDatabase()
    
    let availableFlowers: [Flower] = [
        Flower(flowerId: 1, flowerName: "Marigold", flowerColor: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0), emotion: "Fondness"),
        Flower(flowerId: 2, flowerName: "Rose", flowerColor: UIColor(red: 1.0, green: 0.4, blue: 0.5, alpha: 1.0), emotion: "Love"),
        Flower(flowerId: 3, flowerName: "Tulip", flowerColor: UIColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 1.0), emotion: "Joy"),
        Flower(flowerId: 4, flowerName: "Lily", flowerColor: UIColor(red: 0.95, green: 0.8, blue: 1.0, alpha: 1.0), emotion: "Purity"),
        Flower(flowerId: 5, flowerName: "Daisy", flowerColor: UIColor(red: 1.0, green: 0.95, blue: 0.5, alpha: 1.0), emotion: "Innocence"),
        Flower(flowerId: 6, flowerName: "Violet", flowerColor: UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0), emotion: "Sadness"),
        Flower(flowerId: 7, flowerName: "Sunflower", flowerColor: UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0), emotion: "Happiness"),
        Flower(flowerId: 8, flowerName: "Carnation", flowerColor: UIColor(red: 1.0, green: 0.5, blue: 0.6, alpha: 1.0), emotion: "Gratitude"),
    ]
    
    func getFlower(byEmotion emotion: String) -> Flower? {
        return availableFlowers.first { $0.emotion == emotion }
    }
    
    func getFlower(byId id: Int) -> Flower? {
        return availableFlowers.first { $0.flowerId == id }
    }
}

// MARK: - Sample Story Requirements

class StoryRequirementsDatabase {
    static let shared = StoryRequirementsDatabase()
    
    func getRequirements(for storyId: String) -> StoryFlowerRequirements? {
        // Sample story requirements
        let sampleRequirements: [String: StoryFlowerRequirements] = [
            "story_graduation": StoryFlowerRequirements(
                storyId: "story_graduation",
                requirements: [
                    FlowerRequirement(
                        emotion: "Joy",
                        minimumCount: 1,
                        idealCount: 4,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Joy")!
                    ),
                    FlowerRequirement(
                        emotion: "Happiness",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Happiness")!
                    )
                ],
                hintText: "For her graduation, something joyful and happy"
            ),
            "story_sadness": StoryFlowerRequirements(
                storyId: "story_sadness",
                requirements: [
                    FlowerRequirement(
                        emotion: "Sadness",
                        minimumCount: 1,
                        idealCount: 3,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Sadness")!
                    ),
                    FlowerRequirement(
                        emotion: "Fondness",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Fondness")!
                    )
                ],
                hintText: "I feel so sad, but I remember our fondness"
            ),
            // Default/Test story
            "story_default": StoryFlowerRequirements(
                storyId: "story_default",
                requirements: [
                    FlowerRequirement(
                        emotion: "Love",
                        minimumCount: 1,
                        idealCount: 3,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Love")!
                    )
                ],
                hintText: "Express your love with flowers"
            )
        ]
        
        return sampleRequirements[storyId] ?? sampleRequirements["story_default"]
    }
}
