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
    
    // Based on available flower assets: Rose, Jasmine, Lavender, Hibiscus
    let availableFlowers: [Flower] = [
        Flower(flowerId: 1, flowerName: "Rose", flowerColor: UIColor(red: 1.0, green: 0.4, blue: 0.5, alpha: 1.0), emotion: "Love"),
        Flower(flowerId: 2, flowerName: "Jasmine", flowerColor: UIColor(red: 1.0, green: 0.98, blue: 0.94, alpha: 1.0), emotion: "Purity"),
        Flower(flowerId: 3, flowerName: "Lavender", flowerColor: UIColor(red: 0.7, green: 0.5, blue: 0.85, alpha: 1.0), emotion: "Serenity"),
        Flower(flowerId: 4, flowerName: "Hibiscus", flowerColor: UIColor(red: 1.0, green: 0.3, blue: 0.5, alpha: 1.0), emotion: "Joy"),
    ]
    
    func getFlower(byEmotion emotion: String) -> Flower? {
        return availableFlowers.first { $0.emotion == emotion }
    }
    
    func getFlower(byId id: Int) -> Flower? {
        return availableFlowers.first { $0.flowerId == id }
    }
    
    func getFlower(byName name: String) -> Flower? {
        return availableFlowers.first { $0.flowerName == name }
    }
}

// MARK: - Sample Story Requirements

class StoryRequirementsDatabase {
    static let shared = StoryRequirementsDatabase()
    
    func getRequirements(for storyId: String) -> StoryFlowerRequirements? {
        // Sample story requirements using available flowers
        let sampleRequirements: [String: StoryFlowerRequirements] = [
            "story_wedding": StoryFlowerRequirements(
                storyId: "story_wedding",
                requirements: [
                    FlowerRequirement(
                        emotion: "Love",
                        minimumCount: 1,
                        idealCount: 3,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Love")!
                    ),
                    FlowerRequirement(
                        emotion: "Purity",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Purity")!
                    )
                ],
                hintText: "For a wedding, filled with love and purity"
            ),
            "story_peace": StoryFlowerRequirements(
                storyId: "story_peace",
                requirements: [
                    FlowerRequirement(
                        emotion: "Serenity",
                        minimumCount: 1,
                        idealCount: 4,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Serenity")!
                    ),
                    FlowerRequirement(
                        emotion: "Purity",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Purity")!
                    )
                ],
                hintText: "Something to bring serenity and peace"
            ),
            "story_celebration": StoryFlowerRequirements(
                storyId: "story_celebration",
                requirements: [
                    FlowerRequirement(
                        emotion: "Joy",
                        minimumCount: 1,
                        idealCount: 4,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Joy")!
                    ),
                    FlowerRequirement(
                        emotion: "Love",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Love")!
                    )
                ],
                hintText: "A celebration of joy and love"
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
