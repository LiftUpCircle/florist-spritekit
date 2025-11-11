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
    @Published var model = MemoriesModel()

    // Navigation state
    @Published var selectedMemoryFolder: MemoriesModel.MemoryFolder?
    @Published var selectedChapter: MemoriesModel.Chapter?
    @Published var selectedCompletedStory: CompletedStory?
    @Published var showChapterList = false

    // Navigate to chapter list when a memory folder is selected
    func selectMemoryFolder(_ folder: MemoriesModel.MemoryFolder) {
        selectedMemoryFolder = folder
        showChapterList = true
        selectedChapter = nil // Reset chapter selection
    }
    
    // Navigate to dialogue history when a completed story is selected
    func selectCompletedStory(_ story: CompletedStory) {
        selectedCompletedStory = story
        showChapterList = true
    }

    // Navigate back to memory folder selection
    func backToFolderSelection() {
        showChapterList = false
        selectedMemoryFolder = nil
        selectedChapter = nil
        selectedCompletedStory = nil
    }

    // Select a chapter to view details
    func selectChapter(_ chapter: MemoriesModel.Chapter) {
        selectedChapter = chapter
    }

    // Get chapters for the currently selected memory folder
    var currentChapters: [MemoriesModel.Chapter] {
        return selectedMemoryFolder?.chapters ?? []
    }
}
