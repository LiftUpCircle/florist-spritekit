//
//  DialogueHistoryEntry.swift
//  florist
//
//  SwiftData model for tracking individual dialogue entries in story history
//

import Foundation
import SwiftData

@Model
final class DialogueHistoryEntry {
    var characterName: String
    var dialogue: String
    var timestamp: Date
    var sceneId: String
    
    init(characterName: String, dialogue: String, timestamp: Date, sceneId: String) {
        self.characterName = characterName
        self.dialogue = dialogue
        self.timestamp = timestamp
        self.sceneId = sceneId
    }
}
