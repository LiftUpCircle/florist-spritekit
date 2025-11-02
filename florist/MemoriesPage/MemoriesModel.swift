//
//  MemoriesModel.swift
//  florist
//
//  Created by Al Amin Dwiesta on 02/11/25.
//

import Foundation

struct MemoriesModel {
    // Represents a memory folder (the 3 rectangles on the main memories page)
    struct MemoryFolder: Identifiable {
        let id: UUID = UUID()
        let title: String
        let chapters: [Chapter]
    }

    // Represents a chapter (5 vertical items on the left side)
    struct Chapter: Identifiable {
        let id: UUID = UUID()
        let title: String
        let description: String
        let savedBouquet: SavedBouquet?
    }

    // Represents a saved bouquet
    struct SavedBouquet: Identifiable {
        let id: UUID = UUID()
        let imageName: String // The image asset name for the bouquet
        let dateCreated: Date
    }

    // Sample data - 3 memory folders
    var memoryFolders: [MemoryFolder] = [
        MemoryFolder(
            title: "A shy Scholar",
            chapters: [
                Chapter(
                    title: "Chapter 1",
                    description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500",
                    savedBouquet: SavedBouquet(imageName: "sample_bouquet", dateCreated: Date())
                ),
                Chapter(
                    title: "Chapter 2",
                    description: "The beginning of a new journey filled with beautiful moments.",
                    savedBouquet: nil
                ),
                Chapter(
                    title: "Chapter 3",
                    description: "A collection of cherished memories from special occasions.",
                    savedBouquet: nil
                ),
                Chapter(
                    title: "Chapter 4",
                    description: "Moments that shaped our story together.",
                    savedBouquet: nil
                ),
                Chapter(
                    title: "Chapter 5",
                    description: "The latest adventures and experiences.",
                    savedBouquet: nil
                )
            ]
        ),
        MemoryFolder(
            title: "A Brave Scholar",
            chapters: [
                Chapter(
                    title: "Chapter 1",
                    description: "The quiet beginning of an intellectual journey.",
                    savedBouquet: SavedBouquet(imageName: "scholar_bouquet", dateCreated: Date())
                ),
                Chapter(
                    title: "Chapter 2",
                    description: "Discovering confidence through knowledge.",
                    savedBouquet: nil
                ),
                Chapter(
                    title: "Chapter 3",
                    description: "Building friendships in unexpected places.",
                    savedBouquet: nil
                ),
                Chapter(
                    title: "Chapter 4",
                    description: "Overcoming challenges and growing stronger.",
                    savedBouquet: nil
                ),
                Chapter(
                    title: "Chapter 5",
                    description: "Finding one's voice and purpose.",
                    savedBouquet: nil
                )
            ]
        ),
        MemoryFolder(
            title: "Race Cars",
            chapters: [
                Chapter(
                    title: "Chapter 1",
                    description: "The first step into the unknown.",
                    savedBouquet: nil
                ),
                Chapter(
                    title: "Chapter 2",
                    description: "Exploring new horizons and possibilities.",
                    savedBouquet: nil
                ),
                Chapter(
                    title: "Chapter 3",
                    description: "Meeting companions along the way.",
                    savedBouquet: nil
                ),
                Chapter(
                    title: "Chapter 4",
                    description: "Facing trials and emerging victorious.",
                    savedBouquet: nil
                ),
                Chapter(
                    title: "Chapter 5",
                    description: "The journey continues with hope.",
                    savedBouquet: nil
                )
            ]
        )
    ]
}
