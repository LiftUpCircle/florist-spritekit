//
//  MemoriesManager.swift
//  florist
//
//  Created by reynaldo on 12/11/25.
//

import Foundation
import UIKit
import Combine

class MemoriesManager: ObservableObject {
    static let shared = MemoriesManager()

    @Published var model = MemoriesModel()

    private init() {
        loadMemories()
    }

    // MARK: - Load/Save

    /// Load memories from disk
    func loadMemories() {
        model = MemoriesPersistenceManager.shared.loadMemories()
        print("✅ MemoriesManager: Loaded memories")
    }

    /// Save memories to disk
    func saveMemories() {
        MemoriesPersistenceManager.shared.saveMemories(model)
        print("✅ MemoriesManager: Saved memories")
    }

    // MARK: - Save Bouquet

    /// Save a bouquet image for a specific story
    /// - Parameters:
    ///   - image: The bouquet image to save
    ///   - storyId: The story ID to associate with
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func saveBouquet(image: UIImage, storyId: String) -> Bool {
        if let updatedModel = MemoriesPersistenceManager.shared.saveBouquetForStory(
            image: image,
            storyId: storyId,
            model: model
        ) {
            model = updatedModel
            print("✅ MemoriesManager: Saved bouquet for story: \(storyId)")
            return true
        } else {
            print("❌ MemoriesManager: Failed to save bouquet for story: \(storyId)")
            return false
        }
    }

    // MARK: - Query Methods

    /// Get a memory by story ID
    func getMemory(storyId: String) -> MemoriesModel.Memory? {
        for folder in model.memoryFolders {
            if let memory = folder.memories.first(where: { $0.storyId == storyId }) {
                return memory
            }
        }
        return nil
    }

    /// Check if a story has a saved bouquet
    func hasSavedBouquet(storyId: String) -> Bool {
        return getMemory(storyId: storyId)?.savedBouquet != nil
    }

    /// Get all completed stories (with saved bouquets)
    func getCompletedStories() -> [String] {
        var completed: [String] = []
        for folder in model.memoryFolders {
            for memory in folder.memories {
                if memory.savedBouquet != nil {
                    completed.append(memory.storyId)
                }
            }
        }
        return completed
    }
}
