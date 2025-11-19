//
//  MemoriesModel.swift
//  florist
//
//  Created by Al Amin Dwiesta on 02/11/25.
//

import Foundation

struct MemoriesModel: Codable {
    // Represents a memory folder (character folder with multiple stories)
    struct MemoryFolder: Identifiable, Codable {
        let id: UUID
        let characterName: String // Character name (e.g., "Alice")
        let characterImage: String // Character image asset name
        var memories: [Memory] // Stories for this character

        // Computed property for backward compatibility
        var title: String { characterName }

        enum CodingKeys: String, CodingKey {
            case id, characterName, characterImage, memories
        }
    }

    // Represents a memory (one completed story with saved bouquet)
    struct Memory: Identifiable, Codable {
        let id: UUID
        let storyId: String // Story identifier to link with story.json
        let title: String // Memory/Story title (e.g., "Chapter 1")
        let description: String // Story description
        var savedBouquet: SavedBouquet? // Optional saved bouquet

        enum CodingKeys: String, CodingKey {
            case id, storyId, title, description, savedBouquet
        }
    }

    // Represents a saved bouquet image
    struct SavedBouquet: Identifiable, Codable {
        let id: UUID
        let imageFileName: String // Filename in Documents directory (e.g., "bouquet_uuid.png")
        let dateCreated: Date

        enum CodingKeys: String, CodingKey {
            case id, imageFileName, dateCreated
        }
    }

    // Sample data - Maria's Last Day - Three Special Customers
    var memoryFolders: [MemoryFolder] = [
        MemoryFolder(
            id: UUID(),
            characterName: "Robert Adikusuma",
            characterImage: "character_temp",
            memories: [
                Memory(
                    id: UUID(),
                    storyId: "robert_1_1",
                    title: "Robert's Bouquet",
                    description: "\"For the wife he still holds dear.\" — Robert wanted flowers that remember the way mornings used to feel, blooms that carry his late wife's memory forward. Love that persists beyond time.",
                    savedBouquet: nil
                )
            ]
        ),
        MemoryFolder(
            id: UUID(),
            characterName: "Abigail Surya Kencana",
            characterImage: "character_temp",
            memories: [
                Memory(
                    id: UUID(),
                    storyId: "abigail_1_1",
                    title: "Abigail's Hope",
                    description: "\"Maybe she'll talk to him...\" — Abigail brought flowers for her mother, hoping they might soften her father's heart about demolishing the shop. Peace that feels safe, not sad.",
                    savedBouquet: nil
                )
            ]
        ),
        MemoryFolder(
            id: UUID(),
            characterName: "Michael Kosasih",
            characterImage: "character_temp",
            memories: [
                Memory(
                    id: UUID(),
                    storyId: "michael_1_1",
                    title: "Michael's Gift",
                    description: "\"Nobody ever makes one for you...\" — Little Michael bought flowers for Maria herself, wanting something yellow so she wouldn't forget to smile. Joy that blooms forward.",
                    savedBouquet: nil
                )
            ]
        )
    ]

    enum CodingKeys: String, CodingKey {
        case memoryFolders
    }
}
