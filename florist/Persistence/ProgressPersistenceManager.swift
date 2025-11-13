//
//  ProgressPersistenceManager.swift
//  florist
//
//  Singleton manager for coordinating all story progress persistence operations
//

import Foundation
import SwiftData

/// Errors that can occur during persistence operations
enum ProgressPersistenceError: LocalizedError {
    case saveFailed(underlying: Error)
    case loadFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case storageQuotaExceeded
    case invalidStoryId
    case corruptedData
    case migrationFailed
    case modelContainerNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save progress: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load progress: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete progress: \(error.localizedDescription)"
        case .storageQuotaExceeded:
            return "Storage limit exceeded. Please complete or delete some stories."
        case .invalidStoryId:
            return "Invalid story identifier provided."
        case .corruptedData:
            return "Progress data is corrupted and cannot be loaded."
        case .migrationFailed:
            return "Failed to migrate progress data to new version."
        case .modelContainerNotAvailable:
            return "Database is not available."
        }
    }
}

/// Singleton manager that coordinates all persistence operations for story progress
@MainActor
final class ProgressPersistenceManager {
    
    // MARK: - Singleton
    
    static let shared = ProgressPersistenceManager()
    
    // MARK: - Properties
    
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    // Debouncing properties
    private var pendingSaveTask: Task<Void, Never>?
    private let saveDebounceInterval: TimeInterval = 2.0
    
    // Storage limits
    private let maxConcurrentProgressRecords = 10
    private let maxDialogueHistoryPerStory = 100
    private let maxStorageSizeBytes: Int64 = 10 * 1024 * 1024 // 10 MB
    
    // Performance tracking
    private var lastSaveLatency: TimeInterval = 0
    private var lastLoadLatency: TimeInterval = 0
    private let targetSaveLatency: TimeInterval = 0.5 // 500ms
    private let targetLoadLatency: TimeInterval = 1.0 // 1s
    
    // MARK: - Initialization
    
    private init() {
        // Private initializer for singleton pattern
    }
    
    /// Initialize the manager with a ModelContainer
    /// - Parameter container: The SwiftData ModelContainer to use for persistence
    func initialize(with container: ModelContainer) {
        self.modelContainer = container
        self.modelContext = ModelContext(container)
    }
    
    // MARK: - Private Helpers
    
    /// Ensures the model context is available
    private func ensureContext() throws -> ModelContext {
        guard let context = modelContext else {
            let error = ProgressPersistenceError.modelContainerNotAvailable
            print("❌ \(error.localizedDescription ?? "Model container not available")")
            throw error
        }
        return context
    }
    
    /// Validates a story ID
    private func validateStoryId(_ storyId: String) throws {
        guard !storyId.isEmpty else {
            let error = ProgressPersistenceError.invalidStoryId
            print("❌ Validation failed: Story ID is empty")
            throw error
        }
        
        // Additional validation: check for valid characters
        let validCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        guard storyId.unicodeScalars.allSatisfy({ validCharacterSet.contains($0) }) else {
            print("❌ Validation failed: Story ID contains invalid characters: \(storyId)")
            throw ProgressPersistenceError.invalidStoryId
        }
        
        // Check reasonable length (1-100 characters)
        guard storyId.count >= 1 && storyId.count <= 100 else {
            print("❌ Validation failed: Story ID length out of bounds: \(storyId.count)")
            throw ProgressPersistenceError.invalidStoryId
        }
    }
    
    /// Validates a scene index against the story's scene count
    /// - Parameters:
    ///   - sceneIndex: The scene index to validate
    ///   - storyId: The story ID for logging purposes
    /// - Throws: ProgressPersistenceError.corruptedData if scene index is invalid
    private func validateSceneIndex(_ sceneIndex: Int, for storyId: String) throws {
        // Scene index must be non-negative
        guard sceneIndex >= 0 else {
            print("❌ Validation failed: Scene index is negative (\(sceneIndex)) for story: \(storyId)")
            throw ProgressPersistenceError.corruptedData
        }
        
        // Scene index should be reasonable (< 10000 scenes)
        guard sceneIndex < 10000 else {
            print("❌ Validation failed: Scene index unreasonably large (\(sceneIndex)) for story: \(storyId)")
            throw ProgressPersistenceError.corruptedData
        }
    }
    
    /// Validates dialogue history data
    /// - Parameter dialogueHistory: The dialogue history to validate
    /// - Throws: ProgressPersistenceError.corruptedData if data is invalid
    private func validateDialogueHistory(_ dialogueHistory: [DialogueEntry]) throws {
        // Check for reasonable size
        guard dialogueHistory.count <= maxDialogueHistoryPerStory * 2 else {
            print("❌ Validation failed: Dialogue history too large (\(dialogueHistory.count) entries)")
            throw ProgressPersistenceError.corruptedData
        }
        
        // Validate each entry has non-empty dialogue
        for (index, entry) in dialogueHistory.enumerated() {
            guard !entry.dialogue.isEmpty else {
                print("❌ Validation failed: Empty dialogue at index \(index)")
                throw ProgressPersistenceError.corruptedData
            }
            
            // Check for reasonable dialogue length (< 10000 characters)
            guard entry.dialogue.count < 10000 else {
                print("❌ Validation failed: Dialogue too long at index \(index): \(entry.dialogue.count) characters")
                throw ProgressPersistenceError.corruptedData
            }
        }
    }
    
    /// Validates a StoryProgress object for data integrity
    /// - Parameter progress: The progress object to validate
    /// - Returns: True if valid, false if corrupted
    private func validateProgressData(_ progress: StoryProgress) -> Bool {
        // Check story ID is not empty
        guard !progress.storyId.isEmpty else {
            print("❌ Corrupted data: Empty story ID in progress record")
            return false
        }
        
        // Check scene index is non-negative
        guard progress.currentSceneIndex >= 0 else {
            print("❌ Corrupted data: Negative scene index (\(progress.currentSceneIndex)) in progress for story: \(progress.storyId)")
            return false
        }
        
        // Check last played date is not in the future
        guard progress.lastPlayedDate <= Date() else {
            print("❌ Corrupted data: Future date in progress for story: \(progress.storyId)")
            return false
        }
        
        // Check dialogue history is reasonable
        guard progress.dialogueHistory.count <= maxDialogueHistoryPerStory * 2 else {
            print("❌ Corrupted data: Dialogue history too large (\(progress.dialogueHistory.count)) for story: \(progress.storyId)")
            return false
        }
        
        return true
    }
    
    /// Converts DialogueEntry to DialogueHistoryEntry
    private func convertToHistoryEntry(_ entry: DialogueEntry, sceneId: String) -> DialogueHistoryEntry {
        return DialogueHistoryEntry(
            characterName: entry.characterName,
            dialogue: entry.dialogue,
            timestamp: entry.timestamp,
            sceneId: sceneId
        )
    }
    
    // MARK: - Public Interface
    
    /// Saves progress for a story with debouncing
    /// - Parameters:
    ///   - storyId: Unique identifier for the story
    ///   - sceneIndex: Current scene index
    ///   - dialogueHistory: Array of dialogue entries viewed
    func saveProgress(storyId: String, sceneIndex: Int, dialogueHistory: [DialogueEntry]) async throws {
        // Validate inputs before proceeding (fast, can run on main thread)
        do {
            try validateStoryId(storyId)
            try validateSceneIndex(sceneIndex, for: storyId)
            try validateDialogueHistory(dialogueHistory)
        } catch {
            print("❌ Save validation failed: \(error.localizedDescription ?? "Unknown error")")
            throw error
        }
        
        let context = try ensureContext()
        
        // Cancel any pending save task
        pendingSaveTask?.cancel()
        
        // Create new debounced save task that runs on background
        pendingSaveTask = Task {
            // Wait for debounce interval
            try? await Task.sleep(nanoseconds: UInt64(saveDebounceInterval * 1_000_000_000))
            
            // Check if task was cancelled
            guard !Task.isCancelled else { return }
            
            // Perform the actual save on background thread
            await Task.detached(priority: .userInitiated) {
                do {
                    try await self.performSaveWithTiming(storyId: storyId, sceneIndex: sceneIndex, dialogueHistory: dialogueHistory, context: context)
                } catch {
                    // Log error but don't throw - silent failure for auto-save
                    print("❌ Auto-save failed for story '\(storyId)' at scene \(sceneIndex): \(error.localizedDescription ?? "Unknown error")")
                }
            }.value
        }
        
        await pendingSaveTask?.value
    }
    
    /// Performs save with performance timing
    private func performSaveWithTiming(storyId: String, sceneIndex: Int, dialogueHistory: [DialogueEntry], context: ModelContext) async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        try await performSave(storyId: storyId, sceneIndex: sceneIndex, dialogueHistory: dialogueHistory, context: context)
        
        let latency = CFAbsoluteTimeGetCurrent() - startTime
        await MainActor.run {
            self.lastSaveLatency = latency
        }
        
        let latencyMs = latency * 1000
        if latency > targetSaveLatency {
            print("⚠️ Save operation exceeded target latency: \(String(format: "%.0f", latencyMs))ms (target: \(String(format: "%.0f", targetSaveLatency * 1000))ms)")
        } else {
            print("⚡ Save operation completed in \(String(format: "%.0f", latencyMs))ms")
        }
    }

    /// Performs the actual save operation
    private func performSave(storyId: String, sceneIndex: Int, dialogueHistory: [DialogueEntry], context: ModelContext) async throws {
        print("💾 Saving progress for story '\(storyId)' at scene \(sceneIndex) with \(dialogueHistory.count) dialogue entries")
        
        // Check storage quota before saving
        do {
            let isWithinQuota = try await checkStorageQuota()
            if !isWithinQuota {
                print("⚠️ Storage quota exceeded, attempting to prune old completions")
                // Try to prune old completions to make space
                try await pruneOldCompletionsIfNeeded()
                
                // Check again after pruning
                let isStillOverQuota = try await calculateTotalStorageUsage() >= maxStorageSizeBytes
                if isStillOverQuota {
                    print("❌ Storage quota still exceeded after pruning")
                    throw ProgressPersistenceError.storageQuotaExceeded
                }
            }
        } catch let error as ProgressPersistenceError {
            throw error
        } catch {
            print("❌ Storage quota check failed: \(error.localizedDescription)")
            throw ProgressPersistenceError.saveFailed(underlying: error)
        }
        
        // Fetch existing progress for this story
        let descriptor = FetchDescriptor<StoryProgress>(
            predicate: #Predicate { $0.storyId == storyId }
        )
        
        let existingProgress: StoryProgress?
        do {
            existingProgress = try context.fetch(descriptor).first
        } catch {
            print("❌ Failed to fetch existing progress: \(error.localizedDescription)")
            throw ProgressPersistenceError.loadFailed(underlying: error)
        }
        
        // Convert dialogue entries to history entries
        let historyEntries = dialogueHistory.suffix(maxDialogueHistoryPerStory).map { entry in
            convertToHistoryEntry(entry, sceneId: "scene_\(sceneIndex)")
        }
        
        if let existing = existingProgress {
            // Update existing progress
            print("📝 Updating existing progress record for story '\(storyId)'")
            existing.currentSceneIndex = sceneIndex
            existing.lastPlayedDate = Date()
            existing.dialogueHistory = historyEntries
        } else {
            // Check if we've reached the concurrent progress limit
            let allProgressDescriptor = FetchDescriptor<StoryProgress>()
            let allProgress: [StoryProgress]
            do {
                allProgress = try context.fetch(allProgressDescriptor)
            } catch {
                print("❌ Failed to fetch all progress records: \(error.localizedDescription)")
                throw ProgressPersistenceError.loadFailed(underlying: error)
            }
            
            if allProgress.count >= maxConcurrentProgressRecords {
                // Remove oldest progress record
                if let oldest = allProgress.min(by: { $0.lastPlayedDate < $1.lastPlayedDate }) {
                    print("🗑️ Removing oldest progress record for story '\(oldest.storyId)' to make room")
                    context.delete(oldest)
                }
            }
            
            // Create new progress record
            print("✨ Creating new progress record for story '\(storyId)'")
            let newProgress = StoryProgress(
                storyId: storyId,
                currentSceneIndex: sceneIndex,
                lastPlayedDate: Date(),
                dialogueHistory: historyEntries
            )
            context.insert(newProgress)
        }
        
        // Save context
        do {
            try context.save()
            print("✅ Successfully saved progress for story '\(storyId)' at scene \(sceneIndex)")
        } catch {
            print("❌ Failed to save context: \(error.localizedDescription)")
            throw ProgressPersistenceError.saveFailed(underlying: error)
        }
    }
    
    /// Loads saved progress for a specific story
    /// - Parameter storyId: Unique identifier for the story
    /// - Returns: StoryProgress object if found, nil otherwise
    func loadProgress(for storyId: String) async throws -> StoryProgress? {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        try validateStoryId(storyId)
        let context = try ensureContext()
        
        print("📖 Loading progress for story '\(storyId)'")
        
        // Perform load operation on background thread
        let result: StoryProgress? = try await Task.detached(priority: .userInitiated) {
            do {
                let descriptor = FetchDescriptor<StoryProgress>(
                    predicate: #Predicate { $0.storyId == storyId }
                )
                
                let results = try context.fetch(descriptor)
                
                guard let progress = results.first else {
                    print("ℹ️ No saved progress found for story '\(storyId)'")
                    return nil
                }
                
                // Validate the loaded data
                guard await self.validateProgressData(progress) else {
                    print("❌ Loaded progress data is corrupted for story '\(storyId)', deleting it")
                    // Delete corrupted data
                    context.delete(progress)
                    try context.save()
                    throw ProgressPersistenceError.corruptedData
                }
                
                print("✅ Successfully loaded progress for story '\(storyId)': scene \(progress.currentSceneIndex), \(progress.dialogueHistory.count) dialogue entries")
                return progress
            } catch let error as ProgressPersistenceError {
                throw error
            } catch {
                print("❌ Failed to load progress for story '\(storyId)': \(error.localizedDescription)")
                throw ProgressPersistenceError.loadFailed(underlying: error)
            }
        }.value
        
        let latency = CFAbsoluteTimeGetCurrent() - startTime
        lastLoadLatency = latency
        
        let latencyMs = latency * 1000
        if latency > targetLoadLatency {
            print("⚠️ Load operation exceeded target latency: \(String(format: "%.0f", latencyMs))ms (target: \(String(format: "%.0f", targetLoadLatency * 1000))ms)")
        } else {
            print("⚡ Load operation completed in \(String(format: "%.0f", latencyMs))ms")
        }
        
        return result
    }
    
    /// Deletes saved progress for a specific story
    /// - Parameter storyId: Unique identifier for the story
    func deleteProgress(for storyId: String) async throws {
        try validateStoryId(storyId)
        let context = try ensureContext()
        
        print("🗑️ Deleting progress for story '\(storyId)'")
        
        do {
            let descriptor = FetchDescriptor<StoryProgress>(
                predicate: #Predicate { $0.storyId == storyId }
            )
            
            let results = try context.fetch(descriptor)
            
            if results.isEmpty {
                print("ℹ️ No progress found to delete for story '\(storyId)'")
                return
            }
            
            for progress in results {
                context.delete(progress)
            }
            
            try context.save()
            print("✅ Successfully deleted \(results.count) progress record(s) for story '\(storyId)'")
        } catch {
            print("❌ Failed to delete progress for story '\(storyId)': \(error.localizedDescription)")
            throw ProgressPersistenceError.deleteFailed(underlying: error)
        }
    }
    
    /// Marks a story as complete and archives its dialogue history
    /// - Parameters:
    ///   - storyId: Unique identifier for the story
    ///   - title: Display title of the story
    ///   - dialogueHistory: Complete dialogue history from the playthrough
    func markStoryComplete(storyId: String, title: String, dialogueHistory: [DialogueEntry]) async throws {
        // Validate inputs
        try validateStoryId(storyId)
        
        guard !title.isEmpty else {
            print("❌ Cannot mark story complete: title is empty")
            throw ProgressPersistenceError.invalidStoryId
        }
        
        guard title.count <= 200 else {
            print("❌ Cannot mark story complete: title too long (\(title.count) characters)")
            throw ProgressPersistenceError.corruptedData
        }
        
        try validateDialogueHistory(dialogueHistory)
        
        let context = try ensureContext()
        
        print("🎉 Marking story '\(storyId)' as complete with title '\(title)'")
        
        do {
            // Check if story is already marked complete
            let descriptor = FetchDescriptor<CompletedStory>(
                predicate: #Predicate { $0.storyId == storyId }
            )
            
            let existingCompletion = try context.fetch(descriptor).first
            
            // Convert dialogue history
            let archivedHistory = dialogueHistory.map { entry in
                convertToHistoryEntry(entry, sceneId: "completed")
            }
            
            if let existing = existingCompletion {
                // Update existing completion record
                print("📝 Updating existing completion record for story '\(storyId)'")
                existing.completionDate = Date()
                existing.storyTitle = title
                existing.archivedDialogueHistory = archivedHistory
            } else {
                // Create new completion record
                print("✨ Creating new completion record for story '\(storyId)'")
                let completion = CompletedStory(
                    storyId: storyId,
                    completionDate: Date(),
                    storyTitle: title,
                    archivedDialogueHistory: archivedHistory
                )
                context.insert(completion)
            }
            
            // Delete in-progress checkpoint
            try await deleteProgress(for: storyId)
            
            try context.save()
            print("✅ Successfully marked story '\(storyId)' as complete")
            
            // Check storage quota and prune if needed
            try await pruneOldCompletionsIfNeeded()
        } catch let error as ProgressPersistenceError {
            throw error
        } catch {
            print("❌ Failed to mark story complete: \(error.localizedDescription)")
            throw ProgressPersistenceError.saveFailed(underlying: error)
        }
    }
    
    /// Retrieves all completed stories
    /// - Returns: Array of CompletedStory objects sorted by completion date (newest first)
    func getCompletedStories() async throws -> [CompletedStory] {
        let context = try ensureContext()
        
        do {
            let descriptor = FetchDescriptor<CompletedStory>(
                sortBy: [SortDescriptor(\.completionDate, order: .reverse)]
            )
            
            return try context.fetch(descriptor)
        } catch {
            throw ProgressPersistenceError.loadFailed(underlying: error)
        }
    }
    
    /// Checks if progress exists for a specific story
    /// - Parameter storyId: Unique identifier for the story
    /// - Returns: True if progress exists, false otherwise
    func hasProgress(for storyId: String) async -> Bool {
        do {
            try validateStoryId(storyId)
            let context = try ensureContext()
            
            let descriptor = FetchDescriptor<StoryProgress>(
                predicate: #Predicate { $0.storyId == storyId }
            )
            
            let count = try context.fetchCount(descriptor)
            return count > 0
        } catch {
            print("⚠️ Error checking for progress: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Retrieves all active story progress records
    /// - Returns: Array of all StoryProgress objects sorted by last played date (most recent first)
    func getAllProgress() async throws -> [StoryProgress] {
        let context = try ensureContext()
        
        do {
            let descriptor = FetchDescriptor<StoryProgress>(
                sortBy: [SortDescriptor(\.lastPlayedDate, order: .reverse)]
            )
            
            return try context.fetch(descriptor)
        } catch {
            throw ProgressPersistenceError.loadFailed(underlying: error)
        }
    }
    
    /// Gets the count of active story progress records
    /// - Returns: Number of stories with saved progress
    func getProgressCount() async throws -> Int {
        let context = try ensureContext()
        
        do {
            let descriptor = FetchDescriptor<StoryProgress>()
            return try context.fetchCount(descriptor)
        } catch {
            throw ProgressPersistenceError.loadFailed(underlying: error)
        }
    }
    
    /// Validates that multiple story progress records are properly isolated
    /// - Returns: Dictionary mapping story IDs to their scene indices
    func validateMultipleStoryProgress() async throws -> [String: Int] {
        let allProgress = try await getAllProgress()
        
        var progressMap: [String: Int] = [:]
        var duplicateStoryIds: [String] = []
        
        for progress in allProgress {
            if progressMap[progress.storyId] != nil {
                duplicateStoryIds.append(progress.storyId)
            }
            progressMap[progress.storyId] = progress.currentSceneIndex
        }
        
        if !duplicateStoryIds.isEmpty {
            print("⚠️ Found duplicate story IDs: \(duplicateStoryIds)")
        }
        
        print("✅ Validated \(progressMap.count) unique story progress records")
        return progressMap
    }
    
    // MARK: - Storage Management
    
    /// Calculates the approximate storage size of a StoryProgress record
    /// Note: Not isolated to main actor so it can be called from background threads
    private nonisolated func calculateStorageSize(for progress: StoryProgress) -> Int64 {
        var size: Int64 = 0
        
        // Story ID (UTF-8 bytes)
        size += Int64(progress.storyId.utf8.count)
        
        // Scene index (Int = 8 bytes)
        size += 8
        
        // Date (8 bytes for timestamp)
        size += 8
        
        // Dialogue history entries
        for entry in progress.dialogueHistory {
            size += Int64(entry.characterName.utf8.count)
            size += Int64(entry.dialogue.utf8.count)
            size += Int64(entry.sceneId.utf8.count)
            size += 8 // timestamp
        }
        
        return size
    }
    
    /// Calculates the approximate storage size of a CompletedStory record
    /// Note: Not isolated to main actor so it can be called from background threads
    private nonisolated func calculateStorageSize(for completedStory: CompletedStory) -> Int64 {
        var size: Int64 = 0
        
        // Story ID (UTF-8 bytes)
        size += Int64(completedStory.storyId.utf8.count)
        
        // Story title (UTF-8 bytes)
        size += Int64(completedStory.storyTitle.utf8.count)
        
        // Completion date (8 bytes for timestamp)
        size += 8
        
        // Archived dialogue history entries
        for entry in completedStory.archivedDialogueHistory {
            size += Int64(entry.characterName.utf8.count)
            size += Int64(entry.dialogue.utf8.count)
            size += Int64(entry.sceneId.utf8.count)
            size += 8 // timestamp
        }
        
        return size
    }
    
    /// Calculates total storage usage for all progress data
    /// - Returns: Total storage size in bytes
    func calculateTotalStorageUsage() async throws -> Int64 {
        let context = try ensureContext()
        
        // Perform calculation on background thread to avoid blocking UI
        return try await Task.detached(priority: .utility) {
            var totalSize: Int64 = 0
            
            // Calculate size of all active progress records
            let progressDescriptor = FetchDescriptor<StoryProgress>()
            let allProgress = try context.fetch(progressDescriptor)
            
            for progress in allProgress {
                totalSize += self.calculateStorageSize(for: progress)
            }
            
            // Calculate size of all completed stories
            let completedDescriptor = FetchDescriptor<CompletedStory>()
            let allCompleted = try context.fetch(completedDescriptor)
            
            for completed in allCompleted {
                totalSize += self.calculateStorageSize(for: completed)
            }
            
            return totalSize
        }.value
    }
    
    /// Checks if storage quota would be exceeded by a new save operation
    /// - Returns: True if storage is within limits, false if quota would be exceeded
    func checkStorageQuota() async throws -> Bool {
        let currentUsage = try await calculateTotalStorageUsage()
        let isWithinLimit = currentUsage < maxStorageSizeBytes
        
        // Log storage usage
        let usageMB = Double(currentUsage) / (1024.0 * 1024.0)
        let limitMB = Double(maxStorageSizeBytes) / (1024.0 * 1024.0)
        print("📊 Storage usage: \(String(format: "%.2f", usageMB)) MB / \(String(format: "%.2f", limitMB)) MB")
        
        return isWithinLimit
    }
    
    /// Logs detailed storage usage statistics
    func logStorageUsage() async throws {
        let context = try ensureContext()
        
        // Perform calculation on background thread
        await Task.detached(priority: .utility) {
            do {
                // Get counts
                let progressDescriptor = FetchDescriptor<StoryProgress>()
                let allProgress = try context.fetch(progressDescriptor)
                let progressCount = allProgress.count
                
                let completedDescriptor = FetchDescriptor<CompletedStory>()
                let allCompleted = try context.fetch(completedDescriptor)
                let completedCount = allCompleted.count
                
                // Calculate sizes
                var progressSize: Int64 = 0
                for progress in allProgress {
                    progressSize += self.calculateStorageSize(for: progress)
                }
                
                var completedSize: Int64 = 0
                for completed in allCompleted {
                    completedSize += self.calculateStorageSize(for: completed)
                }
                
                let totalSize = progressSize + completedSize
                
                // Convert to MB for readability
                let progressMB = Double(progressSize) / (1024.0 * 1024.0)
                let completedMB = Double(completedSize) / (1024.0 * 1024.0)
                let totalMB = Double(totalSize) / (1024.0 * 1024.0)
                let limitMB = Double(self.maxStorageSizeBytes) / (1024.0 * 1024.0)
                let percentUsed = (Double(totalSize) / Double(self.maxStorageSizeBytes)) * 100.0
                
                print("📊 ===== Storage Usage Report =====")
                print("📊 Active Progress Records: \(progressCount) (\(String(format: "%.2f", progressMB)) MB)")
                print("📊 Completed Stories: \(completedCount) (\(String(format: "%.2f", completedMB)) MB)")
                print("📊 Total Usage: \(String(format: "%.2f", totalMB)) MB / \(String(format: "%.2f", limitMB)) MB (\(String(format: "%.1f", percentUsed))%)")
                print("📊 ================================")
            } catch {
                print("❌ Failed to log storage usage: \(error.localizedDescription)")
            }
        }.value
    }
    
    /// Prunes oldest completed stories if storage quota is exceeded
    private func pruneOldCompletionsIfNeeded() async throws {
        let context = try ensureContext()
        
        // Check current storage usage
        let currentUsage = try await calculateTotalStorageUsage()
        
        // If we're under the limit, no pruning needed
        guard currentUsage >= maxStorageSizeBytes else {
            return
        }
        
        print("⚠️ Storage quota exceeded (\(currentUsage) bytes / \(maxStorageSizeBytes) bytes)")
        
        // Get all completed stories sorted by date (oldest first)
        let descriptor = FetchDescriptor<CompletedStory>(
            sortBy: [SortDescriptor(\.completionDate, order: .forward)]
        )
        
        let completedStories = try context.fetch(descriptor)
        
        // Remove oldest completed stories until we're under the limit
        var removedCount = 0
        var currentSize = currentUsage
        
        for story in completedStories {
            // Don't remove all completed stories - keep at least 5
            if completedStories.count - removedCount <= 5 {
                break
            }
            
            let storySize = calculateStorageSize(for: story)
            context.delete(story)
            currentSize -= storySize
            removedCount += 1
            
            // Check if we're now under the limit
            if currentSize < maxStorageSizeBytes {
                break
            }
        }
        
        if removedCount > 0 {
            try context.save()
            let newUsageMB = Double(currentSize) / (1024.0 * 1024.0)
            print("🗑️ Pruned \(removedCount) old completed stories")
            print("📊 New storage usage: \(String(format: "%.2f", newUsageMB)) MB")
        }
    }
    
    /// Forces an immediate save without debouncing (for app termination)
    func forceSave(storyId: String, sceneIndex: Int, dialogueHistory: [DialogueEntry]) async throws {
        // Validate inputs
        try validateStoryId(storyId)
        try validateSceneIndex(sceneIndex, for: storyId)
        try validateDialogueHistory(dialogueHistory)
        
        let context = try ensureContext()
        
        print("⚡ Force saving progress for story '\(storyId)' at scene \(sceneIndex)")
        
        // Cancel any pending debounced save
        pendingSaveTask?.cancel()
        
        // Perform immediate save with timing on background thread
        try await Task.detached(priority: .userInitiated) {
            try await self.performSaveWithTiming(storyId: storyId, sceneIndex: sceneIndex, dialogueHistory: dialogueHistory, context: context)
        }.value
    }
    
    /// Flushes any pending saves immediately (called on app termination/backgrounding)
    func flushPendingSaves() async {
        // If there's a pending save task, cancel it and let it complete immediately
        if let task = pendingSaveTask {
            // The task will complete its save operation
            await task.value
            pendingSaveTask = nil
        }
    }
    
    // MARK: - Performance Monitoring
    
    /// Returns the latency of the last save operation
    /// - Returns: Latency in seconds
    func getLastSaveLatency() -> TimeInterval {
        return lastSaveLatency
    }
    
    /// Returns the latency of the last load operation
    /// - Returns: Latency in seconds
    func getLastLoadLatency() -> TimeInterval {
        return lastLoadLatency
    }
    
    /// Checks if the last save operation met the performance target
    /// - Returns: True if within target, false otherwise
    func isLastSaveWithinTarget() -> Bool {
        return lastSaveLatency <= targetSaveLatency
    }
    
    /// Checks if the last load operation met the performance target
    /// - Returns: True if within target, false otherwise
    func isLastLoadWithinTarget() -> Bool {
        return lastLoadLatency <= targetLoadLatency
    }
    
    /// Logs performance statistics
    func logPerformanceStats() {
        let saveMs = lastSaveLatency * 1000
        let loadMs = lastLoadLatency * 1000
        let saveTargetMs = targetSaveLatency * 1000
        let loadTargetMs = targetLoadLatency * 1000
        
        print("⚡ ===== Performance Statistics =====")
        print("⚡ Last Save: \(String(format: "%.0f", saveMs))ms (target: \(String(format: "%.0f", saveTargetMs))ms) \(isLastSaveWithinTarget() ? "✅" : "⚠️")")
        print("⚡ Last Load: \(String(format: "%.0f", loadMs))ms (target: \(String(format: "%.0f", loadTargetMs))ms) \(isLastLoadWithinTarget() ? "✅" : "⚠️")")
        print("⚡ ===================================")
    }
}
