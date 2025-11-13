//
//  StoryProgress.swift
//  florist
//
//  SwiftData model for tracking user progress in stories
//

import Foundation
import SwiftData

@Model
final class StoryProgress {
    @Attribute(.unique) var storyId: String
    var currentSceneIndex: Int
    var lastPlayedDate: Date
    @Relationship(deleteRule: .cascade) var dialogueHistory: [DialogueHistoryEntry]
    
    init(storyId: String, currentSceneIndex: Int, lastPlayedDate: Date, dialogueHistory: [DialogueHistoryEntry] = []) {
        self.storyId = storyId
        self.currentSceneIndex = currentSceneIndex
        self.lastPlayedDate = lastPlayedDate
        self.dialogueHistory = dialogueHistory
    }
}
