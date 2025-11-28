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
    @Published var lastPlayedStoryId: String? = nil  // Track the actual last played story including part 2
    @Published var lastGamePage: String? = nil  // Track if user was in "listening" or "bouquet" page

    private let completedStoriesKey = "completedStories"
    private let currentStoryIndexKey = "currentStoryIndex"
    private let lastPlayedStoryIdKey = "lastPlayedStoryId"
    private let lastGamePageKey = "lastGamePage"

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
            // Exclude second parts from main progression (they're accessed via hasSecondPart flow)
            allStories = storyIndex.stories
                .filter { $0.value.isSecondPart != true } // Exclude second parts
                .sorted { $0.value.order < $1.value.order }
                .map { $0.key }

            print("📚 Loaded \(allStories.count) stories from story.json: \(allStories)")
        } catch {
            // Fallback to default stories if loading fails
            print("⚠️ Failed to load story index, using defaults: \(error)")
//            allStories = ["prologue", "robert_1_1", "abigail_1_1", "michael_1_1"]
        }
    }

    // MARK: - Story Access

    /// Get the current story ID
    var currentStoryId: String {
        guard currentStoryIndex < allStories.count else {
            return allStories.first ?? "robert_1_1"
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

    /// Check if the game is finished (all stories completed)
    var isGameFinished: Bool {
        return completedCount >= totalStories && totalStories > 0
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
        lastPlayedStoryId = nil
        lastGamePage = nil
        saveProgress()
        print("🔄 All progress reset")
    }

    /// Update the last played story ID
    func updateLastPlayedStory(_ storyId: String) {
        lastPlayedStoryId = storyId
        saveProgress()
        print("📝 Updated last played story to: \(storyId)")
    }

    /// Update the last game page (listening or bouquet)
    func updateLastGamePage(_ page: String) {
        lastGamePage = page
        saveProgress()
        print("📄 Updated last game page to: \(page)")
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
        if let lastPlayed = lastPlayedStoryId {
            UserDefaults.standard.set(lastPlayed, forKey: lastPlayedStoryIdKey)
        }
        if let lastPage = lastGamePage {
            UserDefaults.standard.set(lastPage, forKey: lastGamePageKey)
        }
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

        // Load last played story ID
        if let lastPlayed = UserDefaults.standard.string(forKey: lastPlayedStoryIdKey) {
            lastPlayedStoryId = lastPlayed
        }

        // Load last game page
        if let lastPage = UserDefaults.standard.string(forKey: lastGamePageKey) {
            lastGamePage = lastPage
        }

        print("✅ Loaded progress: Story \(currentStoryIndex + 1)/\(totalStories) - \(completedCount) completed")
        if let lastPlayed = lastPlayedStoryId {
            print("  Last played story: \(lastPlayed)")
        }
        if let lastPage = lastGamePage {
            print("  Last game page: \(lastPage)")
        }
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
