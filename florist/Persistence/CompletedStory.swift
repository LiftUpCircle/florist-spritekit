//
//  CompletedStory.swift
//  florist
//
//  SwiftData model for tracking completed stories in the memories feature
//

import Foundation
import SwiftData

@Model
final class CompletedStory {
    @Attribute(.unique) var storyId: String
    var completionDate: Date
    var storyTitle: String
    @Relationship(deleteRule: .cascade) var archivedDialogueHistory: [DialogueHistoryEntry]
    
    init(storyId: String, completionDate: Date, storyTitle: String, archivedDialogueHistory: [DialogueHistoryEntry] = []) {
        self.storyId = storyId
        self.completionDate = completionDate
        self.storyTitle = storyTitle
        self.archivedDialogueHistory = archivedDialogueHistory
    }
}
