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
    
    // Based on available flower assets: Rose, Jasmine, Lavender, Carnation, Lily, Tulip
    let availableFlowers: [Flower] = [
        Flower(flowerId: 1, flowerName: "Rose", flowerColor: UIColor(red: 1.0, green: 0.4, blue: 0.5, alpha: 1.0), emotion: "Love"),
        Flower(flowerId: 2, flowerName: "Jasmine", flowerColor: UIColor(red: 1.0, green: 0.98, blue: 0.94, alpha: 1.0), emotion: "Purity"),
        Flower(flowerId: 3, flowerName: "Lavender", flowerColor: UIColor(red: 0.7, green: 0.5, blue: 0.85, alpha: 1.0), emotion: "Serenity"),
        Flower(flowerId: 4, flowerName: "Carnation", flowerColor: UIColor(red: 1.0, green: 0.75, blue: 0.8, alpha: 1.0), emotion: "Joy"),
        Flower(flowerId: 5, flowerName: "Lily", flowerColor: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), emotion: "Hope"),
        Flower(flowerId: 6, flowerName: "Tulip", flowerColor: UIColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0), emotion: "Elegance"),
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
            // Robert's Story - Love and Memory
            "story_robert_1": StoryFlowerRequirements(
                storyId: "story_robert_1",
                requirements: [
                    FlowerRequirement(
                        emotion: "Love",
                        minimumCount: 2,
                        idealCount: 4,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Love")!
                    )
                ],
                hintText: "The same kind I used to give her... something that feels alive"
            ),
            // Abigail's Story - Serenity, Hope, and Forgiveness
            "story_abigail_1": StoryFlowerRequirements(
                storyId: "story_abigail_1",
                requirements: [
                    FlowerRequirement(
                        emotion: "Serenity",
                        minimumCount: 2,
                        idealCount: 3,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Serenity")!
                    ),
                    FlowerRequirement(
                        emotion: "Hope",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Hope")!
                    )
                ],
                hintText: "The kind that feels safe... quiet but not sad"
            ),
            // Michael's Story - Joy and Hope
            "story_michael_1": StoryFlowerRequirements(
                storyId: "story_michael_1",
                requirements: [
                    FlowerRequirement(
                        emotion: "Joy",
                        minimumCount: 2,
                        idealCount: 3,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Joy")!
                    ),
                    FlowerRequirement(
                        emotion: "Hope",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Hope")!
                    )
                ],
                hintText: "Something yellow... so you don't forget to smile"
            ),
            // Backward compatibility - default story
            "story": StoryFlowerRequirements(
                storyId: "story",
                requirements: [
                    FlowerRequirement(
                        emotion: "Serenity",
                        minimumCount: 2,
                        idealCount: 3,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Serenity")!
                    ),
                    FlowerRequirement(
                        emotion: "Hope",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Hope")!
                    )
                ],
                hintText: "Something with serenity and hope for a new beginning"
            ),
            "story_1": StoryFlowerRequirements(
                storyId: "story_1",
                requirements: [
                    FlowerRequirement(
                        emotion: "Love",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Love")!
                    ),
                    FlowerRequirement(
                        emotion: "Joy",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Joy")!
                    )
                ],
                hintText: "I felt so much love and joy today"
            ),
            "story_2": StoryFlowerRequirements(
                storyId: "story_2",
                requirements: [
                    FlowerRequirement(
                        emotion: "Serenity",
                        minimumCount: 2,
                        idealCount: 3,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Serenity")!
                    ),
                    FlowerRequirement(
                        emotion: "Purity",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Purity")!
                    )
                ],
                hintText: "I need serenity and purity in my life"
            ),
            "story_3": StoryFlowerRequirements(
                storyId: "story_3",
                requirements: [
                    FlowerRequirement(
                        emotion: "Joy",
                        minimumCount: 2,
                        idealCount: 4,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Joy")!
                    )
                ],
                hintText: "Today is a day full of joy and celebration"
            ),
            "story_4": StoryFlowerRequirements(
                storyId: "story_4",
                requirements: [
                    FlowerRequirement(
                        emotion: "Love",
                        minimumCount: 2,
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
                hintText: "A bouquet of love and purity for the wedding"
            ),
            "story_5": StoryFlowerRequirements(
                storyId: "story_5",
                requirements: [
                    FlowerRequirement(
                        emotion: "Serenity",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Serenity")!
                    ),
                    FlowerRequirement(
                        emotion: "Joy",
                        minimumCount: 1,
                        idealCount: 2,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Joy")!
                    ),
                    FlowerRequirement(
                        emotion: "Love",
                        minimumCount: 1,
                        idealCount: 1,
                        flower: FlowerDatabase.shared.getFlower(byEmotion: "Love")!
                    )
                ],
                hintText: "I need serenity, joy, and a little love"
            ),
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
