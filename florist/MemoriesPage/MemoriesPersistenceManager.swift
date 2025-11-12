//
//  MemoriesPersistenceManager.swift
//  florist
//
//  Created by reynaldo on 12/11/25.
//

import Foundation
import UIKit

class MemoriesPersistenceManager {
    static let shared = MemoriesPersistenceManager()

    private let filename = "memories.json"

    private init() {}

    // MARK: - File URL

    private func getFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(filename)
    }

    // MARK: - Save Memories

    /// Save the entire memories model to JSON
    /// - Parameter model: The MemoriesModel to save
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func saveMemories(_ model: MemoriesModel) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(model)
            try data.write(to: getFileURL())
            print("✅ Saved memories to \(filename)")
            return true
        } catch {
            print("❌ Error saving memories: \(error)")
            return false
        }
    }

    // MARK: - Load Memories

    /// Load memories model from JSON
    /// - Returns: The loaded MemoriesModel, or a new default model if load fails
    func loadMemories() -> MemoriesModel {
        let fileURL = getFileURL()

        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("⚠️ No saved memories found, using default model")
            return MemoriesModel()
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = try Data(contentsOf: fileURL)
            let model = try decoder.decode(MemoriesModel.self, from: data)
            print("✅ Loaded memories from \(filename)")
            return model
        } catch {
            print("❌ Error loading memories: \(error)")
            print("⚠️ Using default model")
            return MemoriesModel()
        }
    }

    // MARK: - Save Bouquet to Memory

    /// Save a bouquet image for a specific story
    /// - Parameters:
    ///   - image: The bouquet image to save
    ///   - storyId: The story ID to associate with
    ///   - model: The current memories model
    /// - Returns: The updated memories model, or nil if save failed
    func saveBouquetForStory(image: UIImage, storyId: String, model: MemoriesModel) -> MemoriesModel? {
        // Save the image first
        guard let filename = BouquetImageManager.shared.saveBouquetImage(image) else {
            print("❌ Failed to save bouquet image")
            return nil
        }

        // Create saved bouquet
        let savedBouquet = MemoriesModel.SavedBouquet(
            id: UUID(),
            imageFileName: filename,
            dateCreated: Date()
        )

        // Update the model
        var updatedModel = model

        // Find the memory with matching storyId and update it
        for (folderIndex, folder) in updatedModel.memoryFolders.enumerated() {
            for (memoryIndex, memory) in folder.memories.enumerated() {
                if memory.storyId == storyId {
                    updatedModel.memoryFolders[folderIndex].memories[memoryIndex].savedBouquet = savedBouquet
                    print("✅ Updated memory for story: \(storyId)")

                    // Save the updated model
                    if saveMemories(updatedModel) {
                        return updatedModel
                    } else {
                        // If save failed, delete the image we just created
                        BouquetImageManager.shared.deleteBouquetImage(filename: filename)
                        return nil
                    }
                }
            }
        }

        print("⚠️ Story ID not found: \(storyId)")
        // Clean up the image since we didn't use it
        BouquetImageManager.shared.deleteBouquetImage(filename: filename)
        return nil
    }

    // MARK: - Helper Methods

    /// Delete memories file
    func deleteMemoriesFile() {
        let fileURL = getFileURL()
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
            print("✅ Deleted memories file")
        }
    }

    /// Reset all memories (delete JSON file and all bouquet images)
    func resetAllMemories() {
        deleteMemoriesFile()
        BouquetImageManager.shared.clearAllBouquets()
        print("✅ Reset all memories")
    }
}
