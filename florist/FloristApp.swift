//
//  FloristApp.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import SwiftUI
import SwiftData

@main 
struct FloristApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplashScreen = true
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Initialize ModelContainer with schema versioning and migration support
            let container = try Self.createModelContainer()
            modelContainer = container
            
            // Initialize ProgressPersistenceManager with the container
            Task { @MainActor in
                ProgressPersistenceManager.shared.initialize(with: container)
            }
        } catch {
            // Handle initialization errors gracefully
            print("❌ Failed to initialize ModelContainer: \(error.localizedDescription)")
            
            // Attempt fallback: clear data and retry
            if let fallbackContainer = Self.attemptFallbackInitialization() {
                modelContainer = fallbackContainer
                Task { @MainActor in
                    ProgressPersistenceManager.shared.initialize(with: fallbackContainer)
                }
            } else {
                fatalError("Failed to initialize ModelContainer even after fallback: \(error.localizedDescription)")
            }
        }
    }
    
    /// Creates a ModelContainer with schema versioning and migration support
    private static func createModelContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: Schema(versionedSchema: SchemaV1.self),
            isStoredInMemoryOnly: false
        )
        
        return try ModelContainer(
            for: StoryProgress.self,
            CompletedStory.self,
            DialogueHistoryEntry.self,
            migrationPlan: AppSchemaMigrationPlan.self,
            configurations: configuration
        )
    }
    
    /// Attempts to recover from initialization failure by clearing corrupted data
    private static func attemptFallbackInitialization() -> ModelContainer? {
        print("⚠️ Attempting fallback initialization by clearing data...")
        
        do {
            // Clear the existing data store
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            // SwiftData stores data in a default.store file
            let storeURL = appSupportURL.appendingPathComponent("default.store")
            
            if fileManager.fileExists(atPath: storeURL.path) {
                try fileManager.removeItem(at: storeURL)
                print("✅ Cleared corrupted data store")
            }
            
            // Try creating container again with fresh data
            let container = try createModelContainer()
            print("✅ Successfully initialized with fresh data store")
            return container
            
        } catch {
            print("❌ Fallback initialization failed: \(error.localizedDescription)")
            return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            if showSplashScreen {
                SplashScreenView {
                    showSplashScreen = false
                }
            } else {
                MainMenuView()
                    .modelContainer(modelContainer)
                    .preferredColorScheme(.light)
                    .dynamicTypeSize(.medium)
                    .environmentObject(TextSizeManager.shared)
                    .onAppear {
                        // Lock orientation to landscape
                        AppDelegate.orientationLock = .landscape
                    }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    /// Handles scene phase changes to ensure progress is saved on app termination
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            // App is entering background - trigger final save
            Task { @MainActor in
                await ProgressPersistenceManager.shared.flushPendingSaves()
            }
        case .inactive:
            // App is becoming inactive - prepare for potential termination
            Task { @MainActor in
                await ProgressPersistenceManager.shared.flushPendingSaves()
            }
        case .active:
            // App is active - no action needed
            break
        @unknown default:
            break
        }
    }
}
