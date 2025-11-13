//
//  GameProgressManager.swift
//  florist
//
//  Created by reynaldo on 12/11/25.
//

import Foundation
import Combine

class GameProgressManager: ObservableObject {
    static let shared = GameProgressManager()

    // Dynamically loaded stories from story.json
    private var allStories: [String] = []

    @Published var currentStoryIndex: Int = 0
    @Published var completedStories: Set<String> = []

    private let completedStoriesKey = "completedStories"
    private let currentStoryIndexKey = "currentStoryIndex"

    private init() {
        // Load available stories from story.json
        loadAvailableStories()
        // Then load user progress
        loadProgress()
    }

    /// Load available stories dynamically from story.json
    private func loadAvailableStories() {
        do {
            let storyIndex = try StoryManager.shared.loadStoryIndex()

            // Sort stories by their order field and extract the keys
            allStories = storyIndex.stories
                .sorted { $0.value.order < $1.value.order }
                .map { $0.key }

            print("📚 Loaded \(allStories.count) stories from story.json: \(allStories)")
        } catch {
            // Fallback to default stories if loading fails
            print("⚠️ Failed to load story index, using defaults: \(error)")
            allStories = ["urutan1", "urutan2", "urutan3"]
        }
    }

    // MARK: - Story Access

    /// Get the current story ID
    var currentStoryId: String {
        guard currentStoryIndex < allStories.count else {
            return allStories.first ?? "urutan1"
        }
        return allStories[currentStoryIndex]
    }

    /// Get the next story ID (or nil if no more stories)
    var nextStoryId: String? {
        let nextIndex = currentStoryIndex + 1
        guard nextIndex < allStories.count else { return nil }
        return allStories[nextIndex]
    }

    /// Check if there are more stories available
    var hasMoreStories: Bool {
        return currentStoryIndex < allStories.count - 1
    }

    /// Get total number of stories
    var totalStories: Int {
        return allStories.count
    }

    /// Get number of completed stories
    var completedCount: Int {
        return completedStories.count
    }

    // MARK: - Story Progression

    /// Mark current story as complete and move to next
    func completeCurrentStory() {
        let storyId = currentStoryId
        completedStories.insert(storyId)
        saveProgress()
        print("✅ Story completed: \(storyId) (\(completedCount)/\(totalStories))")
    }

    /// Move to the next story
    func moveToNextStory() {
        if hasMoreStories {
            currentStoryIndex += 1
            saveProgress()  // Save the new story index
            print("➡️ Moving to story: \(currentStoryId)")
        } else {
            print("🎉 All stories completed!")
        }
    }

    /// Reset to first story
    func resetToFirstStory() {
        currentStoryIndex = 0
        saveProgress()  // Save the reset index
        print("🔄 Reset to first story: \(currentStoryId)")
    }

    /// Reset all progress
    func resetAllProgress() {
        currentStoryIndex = 0
        completedStories.removeAll()
        saveProgress()
        print("🔄 All progress reset")
    }

    /// Reload available stories from story.json (useful after adding new stories)
    func reloadAvailableStories() {
        loadAvailableStories()
        // Ensure current index is still valid
        if currentStoryIndex >= allStories.count {
            currentStoryIndex = 0
            saveProgress()
        }
    }

    // MARK: - Persistence

    private func saveProgress() {
        let completedArray = Array(completedStories)
        UserDefaults.standard.set(completedArray, forKey: completedStoriesKey)
        UserDefaults.standard.set(currentStoryIndex, forKey: currentStoryIndexKey)
    }

    private func loadProgress() {
        // Load completed stories
        if let saved = UserDefaults.standard.array(forKey: completedStoriesKey) as? [String] {
            completedStories = Set(saved)
        }

        // Load current story index
        let savedIndex = UserDefaults.standard.integer(forKey: currentStoryIndexKey)
        // Ensure the saved index is valid
        if savedIndex >= 0 && savedIndex < allStories.count {
            currentStoryIndex = savedIndex
        }

        print("✅ Loaded progress: Story \(currentStoryIndex + 1)/\(totalStories) - \(completedCount) completed")
    }

    // MARK: - Query Methods

    /// Check if a specific story is completed
    func isStoryCompleted(_ storyId: String) -> Bool {
        return completedStories.contains(storyId)
    }

    /// Get all story IDs
    func getAllStoryIds() -> [String] {
        return allStories
    }
}
