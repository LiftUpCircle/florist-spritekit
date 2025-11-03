//
//  StoryIntegrationHelper.swift
//  florist
//
//  Created by reynaldo on 03/11/25.
//
//  This file provides helper functions for integrating the Listening Page
//  with the Bouquet Page story requirements system.

import Foundation
import UIKit

/// Helper class for managing story progression and bouquet requirements
class StoryIntegrationHelper {
    static let shared = StoryIntegrationHelper()
    
    private init() {}
    
    // MARK: - Story Data
    
    /// Example of how to create story requirements from Listening Page data
    /// Call this when transitioning from Listening Page to Bouquet Page
    func createStoryRequirements(
        storyId: String,
        emotions: [String: (minimum: Int, ideal: Int)],
        hintText: String
    ) -> StoryFlowerRequirements {
        
        var requirements: [FlowerRequirement] = []
        
        for (emotion, counts) in emotions {
            if let flower = FlowerDatabase.shared.getFlower(byEmotion: emotion) {
                let requirement = FlowerRequirement(
                    emotion: emotion,
                    minimumCount: counts.minimum,
                    idealCount: counts.ideal,
                    flower: flower
                )
                requirements.append(requirement)
            }
        }
        
        return StoryFlowerRequirements(
            storyId: storyId,
            requirements: requirements,
            hintText: hintText
        )
    }
    
    // MARK: - Example Usage
    
    /// Example: Creating requirements for a graduation story
    func exampleGraduationStory() -> StoryFlowerRequirements {
        return createStoryRequirements(
            storyId: "graduation_001",
            emotions: [
                "Joy": (minimum: 1, ideal: 4),
                "Happiness": (minimum: 1, ideal: 2)
            ],
            hintText: "For her graduation, something joyful and happy"
        )
    }
    
    /// Example: Creating requirements for a comfort story
    func exampleComfortStory() -> StoryFlowerRequirements {
        return createStoryRequirements(
            storyId: "comfort_001",
            emotions: [
                "Sadness": (minimum: 1, ideal: 3),
                "Fondness": (minimum: 1, ideal: 2)
            ],
            hintText: "I feel so sad, but I remember our fondness"
        )
    }
    
    /// Example: Creating requirements for a love confession
    func exampleLoveStory() -> StoryFlowerRequirements {
        return createStoryRequirements(
            storyId: "love_001",
            emotions: [
                "Love": (minimum: 2, ideal: 5),
                "Joy": (minimum: 1, ideal: 1)
            ],
            hintText: "I want to confess my love with beautiful flowers"
        )
    }
    
    // MARK: - Integration with Conversation System
    
    /// Parse conversations to extract emotion keywords and create requirements
    /// This is a placeholder for future implementation
    func extractRequirementsFromConversations(
        conversations: [String],
        storyId: String
    ) -> StoryFlowerRequirements? {
        
        // TODO: Implement NLP or keyword matching to detect emotions in conversations
        // For now, return a default requirement
        
        // Example logic (to be implemented):
        // 1. Scan conversations for emotion keywords
        // 2. Count occurrences
        // 3. Map to flower requirements
        // 4. Generate hint text from key conversation phrases
        
        // Placeholder return
        return StoryRequirementsDatabase.shared.getRequirements(for: storyId)
    }
    
    // MARK: - Highlighted Text Helper
    
    /// Generate attributed string for hint text with emotion-colored highlights
    /// This can be used to color-code emotion words in the hint
    func createHighlightedHintText(
        hintText: String,
        requirements: [FlowerRequirement]
    ) -> [(text: String, color: UIColor?)] {
        
        var segments: [(text: String, color: UIColor?)] = []
        var remainingText = hintText
        
        // For each requirement, find and highlight the emotion word
        for requirement in requirements {
            let emotionLower = requirement.emotion.lowercased()
            
            if let range = remainingText.lowercased().range(of: emotionLower) {
                // Add text before the emotion
                let beforeText = String(remainingText[..<range.lowerBound])
                if !beforeText.isEmpty {
                    segments.append((beforeText, nil as UIColor?))
                }
                
                // Add highlighted emotion
                let emotionText = String(remainingText[range])
                segments.append((emotionText, requirement.flower.flowerColor))
                
                // Update remaining text
                remainingText = String(remainingText[range.upperBound...])
            }
        }
        
        // Add any remaining text
        if !remainingText.isEmpty {
            segments.append((remainingText, nil as UIColor?))
        }
        
        return segments
    }
}

// MARK: - Navigation Helper

extension StoryIntegrationHelper {
    
    /// Prepare data for transitioning from Listening Page to Bouquet Page
    struct BouquetTransitionData {
        let storyId: String
        let requirements: StoryFlowerRequirements
        let characterName: String
        let isUniqueCharacter: Bool
    }
    
    /// Create transition data for navigation
    func prepareBouquetTransition(
        storyId: String,
        characterName: String,
        isUnique: Bool
    ) -> BouquetTransitionData {
        
        let requirements = StoryRequirementsDatabase.shared.getRequirements(for: storyId)
            ?? StoryRequirementsDatabase.shared.getRequirements(for: "story_default")!
        
        return BouquetTransitionData(
            storyId: storyId,
            requirements: requirements,
            characterName: characterName,
            isUniqueCharacter: isUnique
        )
    }
}

// MARK: - Usage Example in ListeningPage

/*
 In your ListeningView or ListeningViewController:
 
 func onConversationComplete() {
     // When all conversations are done, transition to Bouquet Page
     let transitionData = StoryIntegrationHelper.shared.prepareBouquetTransition(
         storyId: currentStory.storyId,
         characterName: currentCharacter.name,
         isUnique: currentCharacter.isUnique
     )
     
     // Navigate to BouquetView and pass requirements
     navigateToBouquetPage(with: transitionData.requirements)
 }
 
 func navigateToBouquetPage(with requirements: StoryFlowerRequirements) {
     let bouquetView = BouquetView()
     bouquetView.controller.loadStory(storyId: requirements.storyId)
     
     // Present or push the view
     navigationController?.pushViewController(
         UIHostingController(rootView: bouquetView),
         animated: true
     )
 }
*/
