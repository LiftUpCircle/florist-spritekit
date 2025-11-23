//
//  StoryScene.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import Foundation

struct StoryScene: Codable, Identifiable {
    let id: String
    let backgroundImage: String
    let characterSprite: String?
    let characterName: String
    let dialogue: String
    let spritePosition: SpritePosition?
    let storyVoiceOver: String?
    
    enum SpritePosition: String, Codable {
        case left
        case center
        case right
    }
}
