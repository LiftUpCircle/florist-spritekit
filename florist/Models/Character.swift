//
//  Character.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import Foundation

struct Character: Identifiable, Codable {
    let characterId: UUID
    let name: String
    let characterImg: String
    var stories: [Story]

    var id: UUID { characterId }

    init(characterId: UUID = UUID(), name: String, characterImg: String, stories: [Story] = []) {
        self.characterId = characterId
        self.name = name
        self.characterImg = characterImg
        self.stories = stories
    }
}
