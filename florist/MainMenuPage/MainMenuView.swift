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
    @State private var showMemoriesBook = false
    @State private var savedProgress: StoryProgress?

    var body: some View {
        NavigationStack(path: $flowCoordinator.navigationPath) {
            ZStack {
                // Background image
                Image("MainMenuBackground")
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
                            withAnimation {
                                showMemoriesBook = true
                            }
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
                        }
                    }
                    
                    Spacer()
                        .frame(height: 60) // Adjust this to position the button
                }
                .ignoresSafeArea()
                
                // Menu items - centered
                //                VStack(spacing: 20) {
                //                    Spacer()
                //                    
                //                    ForEach(controller.model.menuItems, id: \.self) { item in
                //                        if item == .start {
                //                            // Show two buttons if there's saved progress
                //                            if savedProgress != nil {
                //                                // Continue button
                //                                MenuButton(title: "Continue") {
                //                                    flowCoordinator.startNewGame()
                //                                }
                //                                
                //                                // Show progress info
                ////                                if let progress = savedProgress {
                ////                                    ProgressInfoView(progress: progress)
                ////                                        .padding(.horizontal, 16)
                ////                                        .padding(.bottom, 4)
                ////                                }
                //                                
                //                                // New Game button
                //                                MenuButton(title: "New Game") {
                //                                    startNewGame()
                //                                }
                //                            } else {
                //                                // Just show New Game if no saved progress
                //                                MenuButton(title: "New Game") {
                //                                    flowCoordinator.startNewGame()
                //                                }
                //                            }
                //                        } else {
                //                            MenuButton(title: item.rawValue) {
                //                                handleMenuSelection(item)
                //                            }
                //                        }
                //                    }
                //                    
                //                    Spacer()
                //                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Settings overlay
                if showSettings {
                    SettingsOverlayView(isPresented: $showSettings)
                        .transition(.opacity)
                        .zIndex(100)
                }

                // Memories book overlay
                if showMemoriesBook {
                    MemoriesBookView {
                        withAnimation {
                            showMemoriesBook = false
                        }
                    }
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
                default:
                    EmptyView()
                }
            }
            .task {
                // Check for saved progress when view appears
                await checkForSavedProgress()
            }
            .onAppear {
                // Start main menu BGM
                SettingsManager.shared.playMusic(named: "mainMenuBGM", loops: -1)
            }
            .statusBar(hidden: true)
            .environmentObject(flowCoordinator)
        }
    }
    
    private func handleMenuSelection(_ item: MainMenuModel.MenuItem) {
        switch item {
        case .start:
            // This case is now handled directly in the view
            break
        case .memories:
            flowCoordinator.navigateToMemories()
        case .options:
            withAnimation {
                showSettings = true
            }
        }
    }
    
    private func startNewGame() {
        Task {
            // Delete saved progress
            if let progress = savedProgress {
                try? await ProgressPersistenceManager.shared.deleteProgress(for: progress.storyId)
                await MainActor.run {
                    savedProgress = nil
                }
            }
            await MainActor.run {
                flowCoordinator.startNewGame()
            }
        }
    }
    
    private func checkForSavedProgress() async {
        do {
            // Check for progress for the current story from GameProgressManager
            let currentStoryId = GameProgressManager.shared.currentStoryId
            let progress = try await ProgressPersistenceManager.shared.loadProgress(for: currentStoryId)
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
