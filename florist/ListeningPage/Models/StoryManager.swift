//
//  StoryManager.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import Foundation

/// Error types that can occur during story loading
enum StoryLoadError: LocalizedError {
    case fileNotFound
    case invalidJSON
    case decodingFailed(Error)
    case emptyStory
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Story file not found in app bundle"
        case .invalidJSON:
            return "Story file contains invalid JSON"
        case .decodingFailed(let error):
            return "Failed to decode story: \(error.localizedDescription)"
        case .emptyStory:
            return "Story file contains no scenes"
        }
    }
}

/// Singleton class responsible for loading and parsing story data from JSON files
class StoryManager {
    static let shared = StoryManager()

    private init() {}

    /// Loads the story index from the main story.json file
    /// - Returns: A StoryIndex object containing all available stories
    /// - Throws: StoryLoadError if the file cannot be found or parsed
    func loadStoryIndex() throws -> StoryIndex {
        guard let url = Bundle.main.url(forResource: "story", withExtension: "json") else {
            throw StoryLoadError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let storyIndex = try decoder.decode(StoryIndex.self, from: data)
            return storyIndex
        } catch let error as DecodingError {
            throw StoryLoadError.decodingFailed(error)
        } catch {
            throw StoryLoadError.invalidJSON
        }
    }

    /// Loads a specific story by its order key (e.g., "urutan1", "urutan2")
    /// - Parameter orderKey: The order key from the story index
    /// - Returns: A StoryData object containing the parsed story
    /// - Throws: StoryLoadError if the story cannot be found or parsed
    func loadStoryByOrder(_ orderKey: String) throws -> StoryData {
        let storyIndex = try loadStoryIndex()

        guard let storyEntry = storyIndex.stories[orderKey] else {
            throw StoryLoadError.fileNotFound
        }

        // Load the individual story file
        let filename = storyEntry.file.replacingOccurrences(of: ".json", with: "")
        let storyData = try loadStoryFromFile(filename)

        // Override the story ID with the order key for persistence
        // We need to create a new StoryData with the order key as ID
        return StoryData(
            id: orderKey,  // Use the order key as the story ID for persistence
            title: storyData.title,
            scenes: storyData.scenes
        )
    }

    /// Loads a story from a specific JSON file in the app bundle
    /// - Parameter filename: The name of the JSON file (without extension)
    /// - Returns: A StoryData object containing the parsed story
    /// - Throws: StoryLoadError if the file cannot be found or parsed
    private func loadStoryFromFile(_ filename: String) throws -> StoryData {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw StoryLoadError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let storyData = try decoder.decode(StoryData.self, from: data)

            // Validate that the story has at least one scene
            guard !storyData.scenes.isEmpty else {
                throw StoryLoadError.emptyStory
            }

            return storyData
        } catch let error as DecodingError {
            throw StoryLoadError.decodingFailed(error)
        } catch let error as StoryLoadError {
            throw error
        } catch {
            throw StoryLoadError.invalidJSON
        }
    }

    /// Legacy method for backward compatibility
    /// Loads a story from a JSON file in the app bundle
    /// - Parameter filename: The name of the JSON file (without extension)
    /// - Returns: A StoryData object containing the parsed story
    /// - Throws: StoryLoadError if the file cannot be found or parsed
    func loadStory(from filename: String) throws -> StoryData {
        // Try to load from the story index first using GameProgressManager's current story
        if filename == "story" {
            do {
                // Get the current story from GameProgressManager
                let currentStoryId = GameProgressManager.shared.currentStoryId
                return try loadStoryByOrder(currentStoryId)
            } catch {
                // If index loading fails, fall back to direct file loading
                return try loadStoryFromFile(filename)
            }
        } else {
            // For specific story files, load directly
            return try loadStoryFromFile(filename)
        }
    }
}
