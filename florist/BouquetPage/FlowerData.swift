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
        print("\n🌺 Validating bouquet for story: \(storyId)")
        print("📋 Requirements:")
        for req in requirements {
            print("   - \(req.emotion): \(req.minimumCount)-\(req.idealCount) (flower: \(req.flower.flowerName))")
        }

        var satisfiedRequirements: [String: Int] = [:]
        var perfectMatches: [String: Bool] = [:]

        // Count flowers by emotion
        print("🌸 Bouquet contents:")
        for flower in bouquet {
            satisfiedRequirements[flower.emotion, default: 0] += 1
            print("   - \(flower.flowerName) (\(flower.emotion))")
        }

        print("📊 Emotion counts in bouquet:")
        for (emotion, count) in satisfiedRequirements {
            print("   - \(emotion): \(count)")
        }

        var allMatch = true
        var allPerfect = true
        var missingEmotions: [String] = []

        print("🔍 Checking requirements:")
        for requirement in requirements {
            let count = satisfiedRequirements[requirement.emotion] ?? 0

            if count < requirement.minimumCount {
                allMatch = false
                allPerfect = false
                missingEmotions.append(requirement.emotion)
                print("   ❌ \(requirement.emotion): has \(count), needs min \(requirement.minimumCount)")
            } else if count < requirement.idealCount {
                allPerfect = false
                perfectMatches[requirement.emotion] = false
                print("   ⚠️ \(requirement.emotion): has \(count), ideal is \(requirement.idealCount)")
            } else {
                perfectMatches[requirement.emotion] = true
                print("   ✅ \(requirement.emotion): has \(count), perfect!")
            }
        }

        let result: ValidationResult
        if !allMatch {
            result = .failure(message: "Hmm, something's missing...", missingEmotions: missingEmotions)
            print("🚫 Result: FAILURE - missing emotions: \(missingEmotions)")
        } else if allPerfect {
            result = .perfectMatch
            print("🌟 Result: PERFECT MATCH!")
        } else {
            result = .goodMatch
            print("👍 Result: GOOD MATCH")
        }

        return result
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

// MARK: - JSON Structures for Story Loading

struct StoryJSONData: Codable {
    let stories: [String: StoryRequirementData]
}

struct StoryRequirementData: Codable {
    let id: String
    let file: String
    let characterId: String
    let characterName: String
    let title: String
    let unlocked: Bool
    let order: Int
    let hintText: String?
    let requirements: [RequirementJSONData]?
}

struct RequirementJSONData: Codable {
    let emotion: String
    let minimumCount: Int
    let idealCount: Int
}

// MARK: - Sample Story Requirements

class StoryRequirementsDatabase {
    static let shared = StoryRequirementsDatabase()
    private var cachedRequirements: [String: StoryFlowerRequirements] = [:]

    init() {
        loadStoriesFromJSON()
        // Keep fallback requirements for compatibility
        loadFallbackRequirements()
    }

    private func loadStoriesFromJSON() {
        // Load story.json the same way StoryManager does - without subdirectory
        guard let url = Bundle.main.url(forResource: "story", withExtension: "json") else {
            print("❌ Could not find story.json file")
            print("📁 Bundle path: \(Bundle.main.bundlePath)")
            return
        }

        print("📄 Found story.json at: \(url.path)")

        do {
            let data = try Data(contentsOf: url)
            print("📊 Loaded \(data.count) bytes from story.json")
            let decoder = JSONDecoder()
            let storyJSON = try decoder.decode(StoryJSONData.self, from: data)

            print("📖 Found \(storyJSON.stories.count) stories in JSON")

            for (key, storyData) in storyJSON.stories {
                print("🔍 Processing story key: '\(key)', id: '\(storyData.id)'")
                print("   - Has requirements: \(storyData.requirements != nil)")
                print("   - Has hintText: \(storyData.hintText != nil)")

                if let requirements = storyData.requirements,
                   let hintText = storyData.hintText {

                    var flowerRequirements: [FlowerRequirement] = []

                    for req in requirements {
                        print("   - Processing requirement: \(req.emotion) (\(req.minimumCount)-\(req.idealCount))")
                        if let flower = FlowerDatabase.shared.getFlower(byEmotion: req.emotion) {
                            let flowerReq = FlowerRequirement(
                                emotion: req.emotion,
                                minimumCount: req.minimumCount,
                                idealCount: req.idealCount,
                                flower: flower
                            )
                            flowerRequirements.append(flowerReq)
                        } else {
                            print("   ⚠️ Could not find flower for emotion: \(req.emotion)")
                        }
                    }

                    let storyReq = StoryFlowerRequirements(
                        storyId: storyData.id,
                        requirements: flowerRequirements,
                        hintText: hintText
                    )

                    // Cache with multiple keys for compatibility:
                    // 1. The key from story.json (e.g., "urutan1")
                    cachedRequirements[key] = storyReq
                    print("   ✓ Cached as '\(key)'")
                    // 2. The story ID (e.g., "story_robert")
                    cachedRequirements[storyData.id] = storyReq
                    print("   ✓ Cached as '\(storyData.id)'")
                    // 3. The story ID with _1 suffix (e.g., "story_robert_1")
                    cachedRequirements["\(storyData.id)_1"] = storyReq
                    print("   ✓ Cached as '\(storyData.id)_1'")
                } else {
                    print("   ⚠️ Skipping story - missing requirements or hintText")
                }
            }

            print("✅ Loaded \(cachedRequirements.count) story requirements from story.json")
        } catch {
            print("❌ Error loading story requirements from JSON: \(error)")
        }
    }

    private func loadFallbackRequirements() {
        // Keep a default fallback requirement for cases where story.json doesn't have requirements
        let defaultRequirement = StoryFlowerRequirements(
            storyId: "story_default",
            requirements: [
                FlowerRequirement(
                    emotion: "Love",
                    minimumCount: 1,
                    idealCount: 3,
                    flower: FlowerDatabase.shared.getFlower(byEmotion: "Love")!
                )
            ],
            hintText: "Express your feelings with flowers"
        )

        // Add default if not already loaded from JSON
        if cachedRequirements["story_default"] == nil {
            cachedRequirements["story_default"] = defaultRequirement
        }
    }

    func getRequirements(for storyId: String) -> StoryFlowerRequirements? {
        print("🔍 Getting requirements for storyId: '\(storyId)'")
        print("📚 Available story IDs in cache: \(cachedRequirements.keys.sorted())")

        // First try to get from cached requirements (loaded from JSON)
        if let requirements = cachedRequirements[storyId] {
            print("✅ Found requirements for '\(storyId)' with hint: '\(requirements.hintText)'")
            return requirements
        }

        print("⚠️ No requirements found for '\(storyId)', using default")
        // Return default requirements as fallback
        return cachedRequirements["story_default"]
    }
}
