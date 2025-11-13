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

    // All available stories in order - Maria's last day at the shop
    private let allStories: [String] = [
        "story_robert_1",    // Customer 1: Robert - Love and Memory
        "story_abigail_1",   // Customer 2: Abigail - Hope and Forgiveness
        "story_michael_1"    // Customer 3: Michael - Joy and Gratitude
    ]

    @Published var currentStoryIndex: Int = 0
    @Published var completedStories: Set<String> = []

    private let userDefaultsKey = "completedStories"

    private init() {
        loadProgress()
    }

    // MARK: - Story Access

    /// Get the current story ID
    var currentStoryId: String {
        guard currentStoryIndex < allStories.count else {
            return allStories.first ?? "story_alice_1"
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
            print("➡️ Moving to story: \(currentStoryId)")
        } else {
            print("🎉 All stories completed!")
        }
    }

    /// Reset to first story
    func resetToFirstStory() {
        currentStoryIndex = 0
        print("🔄 Reset to first story: \(currentStoryId)")
    }

    /// Reset all progress
    func resetAllProgress() {
        currentStoryIndex = 0
        completedStories.removeAll()
        saveProgress()
        print("🔄 All progress reset")
    }

    // MARK: - Persistence

    private func saveProgress() {
        let completedArray = Array(completedStories)
        UserDefaults.standard.set(completedArray, forKey: userDefaultsKey)
        UserDefaults.standard.set(currentStoryIndex, forKey: "currentStoryIndex")
    }

    private func loadProgress() {
        if let saved = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            completedStories = Set(saved)
        }
        currentStoryIndex = UserDefaults.standard.integer(forKey: "currentStoryIndex")
        print("✅ Loaded progress: \(completedCount)/\(totalStories) stories completed")
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
