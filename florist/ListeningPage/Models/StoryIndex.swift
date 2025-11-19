//
//  StoryIndex.swift
//  florist
//
//  created by Al Amin Dwiesta 13/11/2025
//

import Foundation

/// Represents the main story index file structure
struct StoryIndex: Codable {
    let stories: [String: StoryIndexEntry]

    /// Computed property to get total number of stories
    var totalStories: Int {
        return stories.count
    }
}

/// Represents an individual story entry in the index
struct StoryIndexEntry: Codable {
    let id: String
    let file: String
    let characterId: String
    let characterName: String
    let title: String
    let unlocked: Bool
    let order: Int

    // Optional fields for special story types
    let isPrologue: Bool?
    let skipBouquet: Bool?
    let hintText: String?
    let requirements: [StoryFlowerRequirement]?

    // Field to identify second part stories
    let isSecondPart: Bool?
}

/// Represents a flower requirement from story.json
struct StoryFlowerRequirement: Codable {
    let emotion: String
    let minimumCount: Int
    let idealCount: Int
}
