//
//  ListeningPageView.swift
//  florist
//
//  Created by reynaldo on 04/11/25.
//

import SwiftUI

struct ListeningPageView: View {
    let storyId: String
    @ObservedObject var flowCoordinator: GameFlowCoordinator
    @StateObject private var controller = StoryController()
    
    /// Check if the background image exists in the asset catalog
    private func backgroundImageExists(_ imageName: String) -> Bool {
        UIImage(named: imageName) != nil
    }

    /// Map character sprite name to real asset name based on current scene's character
    private func getCharacterAssetName(from spriteName: String) -> String {
        // Check the characterName from the scene to determine which asset to use
        guard let scene = controller.currentScene else {
            return spriteName
        }

        let characterName = scene.characterName.lowercased()

        if characterName.contains("robert") {
            return "robert"
        } else if characterName.contains("abigail") {
            return "abigail"
        } else if characterName.contains("michael") {
            return "michael"
        }

        // Fallback to original sprite name
        return spriteName
    }

    /// Calculate sprite X position based on position enum
    private func spriteXPosition(for position: StoryScene.SpritePosition, in geometry: GeometryProxy) -> CGFloat {
        switch position {
        case .left:
            return geometry.size.width * 0.25
        case .center:
            return geometry.size.width * 0.5
        case .right:
            return geometry.size.width * 0.75
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: Background (stretched to fill or panning for prologue)
                if let backgroundImage = controller.currentScene?.backgroundImage {
                    if backgroundImageExists(backgroundImage) {
                        // Check if this is the prologue background
                        if backgroundImage == "BackgroundPrologue" {
                            // Use panning background for prologue
                            PanningBackgroundView(imageName: backgroundImage)
                                .accessibilityHidden(true)
                        } else {
                            // Regular background for other scenes
                            Image(backgroundImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .accessibilityHidden(true)
                        }
                    } else {
                        // Fallback solid color background for missing image
                        Color.gray.opacity(0.3)
                            .accessibilityHidden(true)
                            .onAppear {
                                print("⚠️ Warning: Background image '\(backgroundImage)' not found in asset catalog")
                            }
                    }
                } else {
                    // Default background when no background is specified
                    Color.black
                        .accessibilityHidden(true)
                }

                // Layer 1.5: Dark overlay when in conversation (skip for prologue)
                if controller.currentScene != nil {
                    if controller.currentScene?.backgroundImage != "BackgroundPrologue" {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .accessibilityHidden(true)
                    }
                }

                // Layer 2: Character Sprite (positioned based on spritePosition)
                if let scene = controller.currentScene,
                   let sprite = scene.characterSprite {
                    let position = scene.spritePosition ?? .center
                    let xPosition = spriteXPosition(for: position, in: geometry)

                    CharacterSpriteView(
                        spriteName: getCharacterAssetName(from: sprite),
                        position: position
                    )
                    .frame(height: geometry.size.height * 1.8)
                    .position(x: xPosition, y: geometry.size.height * 0.9)
                    .clipped()
                }

                // Layer 2.5: BackgroundTable (in front of character) (skip for prologue)
                if controller.currentScene != nil {
                    if controller.currentScene?.backgroundImage != "BackgroundPrologue" {
                        Image("BackgroundTable")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .accessibilityHidden(true)
                    }
                }

                // Layer 3: Dialogue Box (most front, above table)
                if let scene = controller.currentScene {
                    VStack {
                        Spacer()

                        DialogueTextboxView(
                            characterName: scene.characterName,
                            dialogue: scene.dialogue,
                            typingSpeed: controller.typingSpeed,
                            shouldCompleteTyping: controller.shouldCompleteTyping,
                            maxWidth: geometry.size.width * 0.7,
                            onTypingComplete: { controller.onTypingComplete() },
                            onTap: { controller.handleDialogueTap() }
                        )
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if controller.showError {
                    // Empty state when story fails to load
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.custom("Gaegu-Regular", size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("No Story Loaded")
                            .font(.title2Gaegu)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("The story could not be loaded. Please check that the story file exists and is properly formatted.")
                            .font(.bodyGaegu)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.7))
                    )
                    .padding(.horizontal, 20)
                }

                // Layer 4: Skip Button (top-right)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            controller.skipStory()
                        }) {
                            Image("SkipButton")
                                .resizable()
                                .opacity(0.7)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90, height: 50)
                        }
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }

                // Layer 5: Control Container (bottom-right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ControlContainerView(
                            onSettingsTap: { controller.openSettings() },
                            onLogTap: { controller.openDialogueHistory() }
                        )
                        .padding(.bottom, 30)
                        .padding(.trailing, 20)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            if !controller.isStoryComplete {
                if !controller.isTypingComplete {
                    // Complete typing on first tap
                    controller.completeCurrentTyping()
                } else {
                    // Advance to next scene on second tap
                    controller.advanceToNextScene()
                }
            }
        }
        .accessibilityAction(named: "Advance to next scene") {
            if !controller.isStoryComplete && controller.isTypingComplete {
                controller.advanceToNextScene()
            }
        }
        .sheet(isPresented: $controller.showDialogueHistory) {
            DialogueHistoryView(entries: controller.dialogueHistory)
        }
        .overlay {
            if controller.showSettings {
                SettingsOverlayView(isPresented: $controller.showSettings) {
                    // Navigate to main menu
                    flowCoordinator.returnToMainMenu()
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .settingsOverlayDidTapHomeButton)) { _ in
            // Handle notification for navigation to main menu
            flowCoordinator.returnToMainMenu()
            // Close settings if open
            controller.showSettings = false
        }
        .alert("Error", isPresented: $controller.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(controller.errorMessage ?? "An unknown error occurred")
        }
        .navigationBarHidden(true)
        .onAppear {
            // Set the flow coordinator for progress restoration
            controller.setFlowCoordinator(flowCoordinator)

            // Map story ID to order key or load directly
            // storyId can be: "robert_1_1", "abigail_1_1", etc. for new structure
            // or "story" for legacy/default loading
            if storyId.contains("_") {
                controller.loadStoryByOrder(storyId)
            } else {
                // Default behavior - loads the current story from the index
                controller.loadStory(from: "story")
            }

            // Start listening BGM
            SettingsManager.shared.playMusic(named: "listeningBGM", loops: -1)
        }
        .onChange(of: controller.isStoryComplete) { _, isComplete in
            if isComplete {
                // Check if this story should skip bouquet (e.g., prologue)
                do {
                    let storyIndex = try StoryManager.shared.loadStoryIndex()
                    if let storyEntry = storyIndex.stories[storyId],
                       storyEntry.skipBouquet == true {
                        // Skip bouquet, go directly to next story
                        // Pass the storyId so we know which story just completed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            flowCoordinator.onStoryCompleteNoBouquet(for: storyId)
                        }
                    } else {
                        // Normal flow - go to bouquet
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            flowCoordinator.navigateToBouquet(storyId: storyId)
                        }
                    }
                } catch {
                    // Default to normal flow if we can't load story index
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        flowCoordinator.navigateToBouquet(storyId: storyId)
                    }
                }
            }
        }
        .onDisappear {
            // Save progress when navigating away from the story
            Task {
                await controller.saveCurrentProgress()
            }
        }
    }
}


#Preview {
    ListeningPageView(storyId: "story", flowCoordinator: GameFlowCoordinator())
}
