//
//  CharacterAppearanceTracker.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 11/11/25.
//

import Foundation


class CharacterAppearanceTracker {
    static let shared = CharacterAppearanceTracker()
    
    private var appearedCharacters: Set<String> = []
    
    private init() {
        
    }
    

    func checkAndMarkFirstAppearance(characterName: String, storyId: String) -> Bool {
        let normalizedName = characterName.lowercased()
        
        
        let isMainCharacter = normalizedName.contains("abigail") || 
                             normalizedName.contains("michael") || 
                             normalizedName.contains("robert")
        
        guard isMainCharacter else { return false }
        

        let isFirstPartStory = isFirstPartStory(storyId: storyId)
        
        guard isFirstPartStory else { return false }
        
        // Check if this character has appeared before
        if !appearedCharacters.contains(normalizedName) {
            // Mark as appeared
            appearedCharacters.insert(normalizedName)
            return true
        }
        
        return false
    }
    
    
    private func isFirstPartStory(storyId: String) -> Bool {
        // Get the filename from the story index to check underscore count
        // Filenames: "story_abigail_1" (2 underscores) = first part
        //           "story_abigail_1_2" (3 underscores) = second part
        do {
            let storyIndex = try StoryManager.shared.loadStoryIndex()
            if let storyEntry = storyIndex.stories[storyId] {
                let filename = storyEntry.file.replacingOccurrences(of: ".json", with: "")
                let underscoreCount = filename.filter { $0 == "_" }.count
                // First part stories have exactly 2 underscores in filename (e.g., "story_abigail_1")
                return underscoreCount == 2
            }
        } catch {
            print("⚠️ Failed to load story index for checking first part: \(error)")
        }
        
        // Fallback: if story ID already looks like a filename with 2 underscores
        if storyId.hasPrefix("story_") {
            let underscoreCount = storyId.filter { $0 == "_" }.count
            return underscoreCount == 2
        }
        
        // Default: not a first part
        return false
    }
    
    /// Resets all character tracking (e.g., when starting a new game)
    func reset() {
        appearedCharacters.removeAll()
    }
    
    /// Marks a character as already appeared (useful when restoring progress)
    func markAsAppeared(characterName: String) {
        let normalizedName = characterName.lowercased()
        if normalizedName.contains("abigail") || 
           normalizedName.contains("michael") || 
           normalizedName.contains("robert") {
            appearedCharacters.insert(normalizedName)
        }
    }
}

