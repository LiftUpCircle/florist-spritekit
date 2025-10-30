//
//  Story.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import Foundation

struct Story: Identifiable, Codable {
    let storyId: Int
    let character: Character
    let flowerRequirement: [Flower]
    var conversations: [Conversation]
    var savedBoquet: SavedBoquet?

    var id: Int { storyId }

    init(storyId: Int, character: Character, flowerRequirement: [Flower], conversations: [Conversation] = [], savedBoquet: SavedBoquet? = nil) {
        self.storyId = storyId
        self.character = character
        self.flowerRequirement = flowerRequirement
        self.conversations = conversations
        self.savedBoquet = savedBoquet
    }
}
