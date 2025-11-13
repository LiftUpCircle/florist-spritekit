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
    let currentStory: String
    let totalStories: Int
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
}
