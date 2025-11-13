//
//  BouquetImageManager.swift
//  florist
//
//  Created by reynaldo on 12/11/25.
//

import Foundation
import UIKit

class BouquetImageManager {
    static let shared = BouquetImageManager()

    private init() {}

    // MARK: - Directory Management

    /// Get the Documents directory URL
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Get the bouquets subdirectory URL (creates if doesn't exist)
    private func getBouquetsDirectory() -> URL {
        let bouquetsDir = getDocumentsDirectory().appendingPathComponent("SavedBouquets")

        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: bouquetsDir.path) {
            try? FileManager.default.createDirectory(at: bouquetsDir, withIntermediateDirectories: true)
        }

        return bouquetsDir
    }

    // MARK: - Save Image

    /// Save a UIImage to Documents directory and return the filename
    /// - Parameter image: The bouquet image to save
    /// - Returns: The filename (UUID.png) if successful, nil otherwise
    func saveBouquetImage(_ image: UIImage) -> String? {
        // Generate unique filename
        let filename = "\(UUID().uuidString).png"
        let fileURL = getBouquetsDirectory().appendingPathComponent(filename)

        // Convert image to PNG data
        guard let pngData = image.pngData() else {
            print("❌ Failed to convert image to PNG data")
            return nil
        }

        // Write to file
        do {
            try pngData.write(to: fileURL)
            print("✅ Saved bouquet image: \(filename)")
            return filename
        } catch {
            print("❌ Error saving bouquet image: \(error)")
            return nil
        }
    }

    // MARK: - Load Image

    /// Load a UIImage from Documents directory
    /// - Parameter filename: The filename to load (e.g., "uuid.png")
    /// - Returns: The UIImage if successful, nil otherwise
    func loadBouquetImage(filename: String) -> UIImage? {
        let fileURL = getBouquetsDirectory().appendingPathComponent(filename)

        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("⚠️ Bouquet image not found: \(filename)")
            return nil
        }

        // Load image
        guard let image = UIImage(contentsOfFile: fileURL.path) else {
            print("❌ Failed to load bouquet image: \(filename)")
            return nil
        }

        return image
    }

    // MARK: - Delete Image

    /// Delete a bouquet image from Documents directory
    /// - Parameter filename: The filename to delete
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func deleteBouquetImage(filename: String) -> Bool {
        let fileURL = getBouquetsDirectory().appendingPathComponent(filename)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("⚠️ Bouquet image doesn't exist: \(filename)")
            return false
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
            print("✅ Deleted bouquet image: \(filename)")
            return true
        } catch {
            print("❌ Error deleting bouquet image: \(error)")
            return false
        }
    }

    // MARK: - Helper Methods

    /// Get all saved bouquet image filenames
    /// - Returns: Array of filenames in the SavedBouquets directory
    func getAllBouquetFilenames() -> [String] {
        let bouquetsDir = getBouquetsDirectory()

        do {
            let files = try FileManager.default.contentsOfDirectory(at: bouquetsDir, includingPropertiesForKeys: nil)
            return files.map { $0.lastPathComponent }
        } catch {
            print("❌ Error listing bouquet files: \(error)")
            return []
        }
    }

    /// Clear all saved bouquet images (use with caution!)
    func clearAllBouquets() {
        let filenames = getAllBouquetFilenames()
        for filename in filenames {
            deleteBouquetImage(filename: filename)
        }
        print("✅ Cleared all saved bouquets (\(filenames.count) files)")
    }
}
