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
                        }
                    }

                    Spacer()
                        .frame(height: 60) // Adjust this to position the button
                }
                .ignoresSafeArea()

                // Settings overlay
                if showSettings {
                    SettingsOverlayView(isPresented: $showSettings)
                        .transition(.opacity)
                        .zIndex(100)
                }
            }
            .ignoresSafeArea()
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
        }
        .statusBar(hidden: true)
        .environmentObject(flowCoordinator)
    }
}

#Preview {
    MainMenuView()
}
