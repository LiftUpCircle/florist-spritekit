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

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: Background (stretched to fill)
                if let backgroundImage = controller.currentScene?.backgroundImage {
                    if backgroundImageExists(backgroundImage) {
                        Image(backgroundImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .accessibilityHidden(true)
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

                // Layer 1.5: Dark overlay when in conversation
                if controller.currentScene != nil {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .accessibilityHidden(true)
                }

                // Layer 2: Character Sprite (centered)
                if let scene = controller.currentScene {
                    ZStack {
                        // Character Sprite
                        if let sprite = scene.characterSprite {
                            CharacterSpriteView(
                                spriteName: getCharacterAssetName(from: sprite),
                                position: .center
                            )
                            .frame(height: geometry.size.height * 1.8)
                            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.9)
                            .clipped()
                        }

                        // Dialogue Box (bottom center, in front of character)
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
                
                // Layer 3: Control Container (top-right)
                VStack {
                    HStack {
                        Spacer()
                        ControlContainerView(
                            onSettingsTap: { controller.openSettings() },
                            onLogTap: { controller.openDialogueHistory() }
                        )
                        .padding(.top, 50)
                        .padding(.trailing, 20)
                    }
                    Spacer()
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
        .sheet(isPresented: $controller.showSettings) {
            StorySettingsView()
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
            // storyId can be: "urutan1", "urutan2", "urutan3" for new structure
            // or "story" for legacy/default loading
            if storyId.starts(with: "urutan") {
                controller.loadStoryByOrder(storyId)
            } else {
                // Default behavior - loads the current story from the index
                controller.loadStory(from: "story")
            }

            // Start listening BGM
            SettingsManager.shared.playMusic(named: "listeningBGM", loops: -1)
        }
        .onChange(of: controller.isStoryComplete) { isComplete in
            if isComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    flowCoordinator.navigateToBouquet(storyId: storyId)
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
