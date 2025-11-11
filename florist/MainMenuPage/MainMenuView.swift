//
//  MainMenuView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var controller = MainMenuViewController()
    @StateObject private var flowCoordinator = GameFlowCoordinator()
    @State private var showSettings = false
    @State private var savedProgress: StoryProgress?
    @State private var showStartOptions = false
    
    var body: some View {
        NavigationStack(path: $flowCoordinator.navigationPath) {
            ZStack {
                // Background image
                Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                // Main content
                VStack {
                    Spacer()
                    // Top area with Memories button
                    HStack {
                        Spacer()
                        
                        // Memories button
                        Button(action: {
                            flowCoordinator.navigateToMemories()
                        }) {
                            Image("MemoriesButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                        }
                        .padding(.top, 60)
                        .padding(.trailing, 50)
                    }
                    
                    // Settings button at bottom right
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                showSettings = true
                            }
                        }) {
                            Image("MainMenuSettingsButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                        }
                        .padding(.bottom, 40)
                        .padding(.trailing, 50)
                    }
                }
                .ignoresSafeArea()

                VStack {
                    Spacer()

                    Button(action: {
                        flowCoordinator.startNewGame()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 35)
                                .fill(Color("PlayButton"))
                                .frame(width: 168, height: 56)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)

                            Text("Tap to Play")
                                .font(.title3Gaegu)
                                .foregroundColor(Color("TextPlayButton"))
                
                VStack(spacing: 40) {
                    ForEach(controller.model.menuItems, id: \.self) { item in
                        if item == .start {
                            // Show "Continue" or "Start" based on saved progress
                            MenuButton(title: savedProgress != nil ? "Continue" : "Start") {
                                handleMenuSelection(item)
                            }
                            .padding(.vertical, 5)
                            
                            // Show progress info if available
                            if let progress = savedProgress {
                                ProgressInfoView(progress: progress)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 8)
                            }
                        } else {
                            MenuButton(title: item.rawValue) {
                                handleMenuSelection(item)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                // Settings overlay
                if showSettings {
                    SettingsOverlayView(isPresented: $showSettings)
                        .transition(.opacity)
                        .zIndex(100)
                }
                
                // Start options overlay (Continue vs Start Fresh)
                if showStartOptions {
                    StartOptionsOverlay(
                        isPresented: $showStartOptions,
                        onContinue: {
                            showStartOptions = false
                            flowCoordinator.startNewGame()
                        },
                        onStartFresh: {
                            showStartOptions = false
                            Task {
                                // Delete saved progress
                                if let progress = savedProgress {
                                    try? await ProgressPersistenceManager.shared.deleteProgress(for: progress.storyId)
                                    savedProgress = nil
                                }
                                flowCoordinator.startNewGame()
                            }
                        }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: GameFlowCoordinator.GamePage.self) { page in
                switch page {
                case .listening(let storyId):
                    ListeningPageView(storyId: storyId, flowCoordinator: flowCoordinator)
                case .bouquet(let storyId):
                    BouquetPageWrapper(storyId: storyId, flowCoordinator: flowCoordinator)
                case .memories:
                    MemoriesView()
                case .options:
                    EmptyView() // Options now handled as overlay
                case .mainMenu:
                    EmptyView() // This shouldn't be reached
                }
            }
            .task {
                // Check for saved progress when view appears
                await checkForSavedProgress()
            }
            .statusBar(hidden: true)
            .environmentObject(flowCoordinator)
        }
    }
    
    private func handleMenuSelection(_ item: MainMenuModel.MenuItem) {
        switch item {
        case .start:
            // If there's saved progress, show options to continue or start fresh
            if savedProgress != nil {
                withAnimation {
                    showStartOptions = true
                }
            } else {
                // No saved progress, start directly
                flowCoordinator.startNewGame()
            }
        case .memories:
            flowCoordinator.navigateToMemories()
        case .options:
            withAnimation {
                showSettings = true
            }
        }
    }
    
    private func checkForSavedProgress() async {
        do {
            // Check for progress for the default story (matches story.json id)
            let progress = try await ProgressPersistenceManager.shared.loadProgress(for: "simple-encounter")
            await MainActor.run {
                savedProgress = progress
            }
        } catch {
            print("⚠️ Failed to check for saved progress: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Progress Info View
    
    struct ProgressInfoView: View {
        let progress: StoryProgress
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Last played: \(formattedDate)")
                    .font(.custom("Arial Rounded MT Bold", size: 14))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("Scene \(progress.currentSceneIndex + 1)")
                    .font(.custom("Arial Rounded MT Bold", size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        private var formattedDate: String {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return formatter.localizedString(for: progress.lastPlayedDate, relativeTo: Date())
        }
    }
    
    // MARK: - Start Options Overlay
    
    struct StartOptionsOverlay: View {
        @Binding var isPresented: Bool
        let onContinue: () -> Void
        let onStartFresh: () -> Void
        
        var body: some View {
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                
                // Options panel
                VStack(spacing: 20) {
                    Text("Continue or Start Fresh?")
                        .font(.custom("Arial Rounded MT Bold", size: 28))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    Button(action: {
                        withAnimation {
                            onContinue()
                        }
                    }) {
                        Text("Continue from last save")
                            .font(.custom("Arial Rounded MT Bold", size: 22))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 32)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green.opacity(0.8))
                            )
                    }
                    
                    Button(action: {
                        withAnimation {
                            onStartFresh()
                        }
                    }) {
                        Text("Start from beginning")
                            .font(.custom("Arial Rounded MT Bold", size: 22))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 32)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.orange.opacity(0.8))
                            )
                    }
                    
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("Cancel")
                            .font(.custom("Arial Rounded MT Bold", size: 18))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 8)
                    }
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.95))
                )
                .shadow(radius: 20)
            }
            
        }
    }
}

struct MenuButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Arial Rounded MT Bold", size: 40))
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.leading, 16)
                .padding(.trailing, 86)
        }
    }
}

#Preview {
    MainMenuView()
}
