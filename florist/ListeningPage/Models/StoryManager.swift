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
    
    /// Loads a story from a JSON file in the app bundle
    /// - Parameter filename: The name of the JSON file (without extension)
    /// - Returns: A StoryData object containing the parsed story
    /// - Throws: StoryLoadError if the file cannot be found or parsed
    func loadStory(from filename: String) throws -> StoryData {
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
}
