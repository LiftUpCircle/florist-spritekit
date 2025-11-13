//
//  MemoriesViewController.swift
//  florist
//
//  Created by Al Amin Dwiesta on 02/11/25.
//

import SwiftUI
import Combine
import SwiftData

class MemoriesViewController: ObservableObject {
    // Use shared MemoriesManager
    private let memoriesManager = MemoriesManager.shared

    // Published model from MemoriesManager
    var model: MemoriesModel {
        memoriesManager.model
    }

    // Navigation state
    @Published var selectedMemoryFolder: MemoriesModel.MemoryFolder?
    @Published var selectedMemory: MemoriesModel.Memory?
    @Published var selectedCompletedStory: CompletedStory?
    @Published var showChapterList = false

    // Initialize and observe MemoriesManager changes
    init() {
        // The MemoriesManager singleton already loads on init
        print("✅ MemoriesViewController initialized with MemoriesManager")
    }

    /// Refreshes saved bouquet data from storage
    func refreshSavedBouquets() {
        // Reload the model from persistence
        memoriesManager.loadMemories()
        print("🔄 Refreshed saved bouquets from MemoriesManager")
    }

    // MARK: - Navigation

    /// Navigate to memory list when a memory folder is selected
    func selectMemoryFolder(_ folder: MemoriesModel.MemoryFolder) {
        selectedMemoryFolder = folder
        showChapterList = true
        selectedMemory = nil // Reset memory selection
    }
    
    // Navigate to dialogue history when a completed story is selected
    func selectCompletedStory(_ story: CompletedStory) {
        selectedCompletedStory = story
        showChapterList = true
    }

    /// Navigate back to memory folder selection
    func backToFolderSelection() {
        showChapterList = false
        selectedMemoryFolder = nil
        selectedMemory = nil
        selectedCompletedStory = nil
    }

    /// Select a memory to view details
    func selectMemory(_ memory: MemoriesModel.Memory) {
        selectedMemory = memory
    }

    // MARK: - Computed Properties

    /// Get memories for the currently selected memory folder
    var currentMemories: [MemoriesModel.Memory] {
        return selectedMemoryFolder?.memories ?? []
    }

    /// Get chapters for the currently selected memory folder (backward compatibility)
    @available(*, deprecated, message: "Use currentMemories instead")
    var currentChapters: [MemoriesModel.Memory] {
        return currentMemories
    }

    /// Select a chapter (backward compatibility wrapper)
    @available(*, deprecated, message: "Use selectMemory instead")
    func selectChapter(_ chapter: MemoriesModel.Memory) {
        selectMemory(chapter)
    }
}
