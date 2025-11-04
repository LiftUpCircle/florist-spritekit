//
//  VNSceneView.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import SwiftUI

struct VNSceneView: View {
    @StateObject private var controller = StoryController()
    
    /// Check if the background image exists in the asset catalog
    private func backgroundImageExists(_ imageName: String) -> Bool {
        UIImage(named: imageName) != nil
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
                
                // Layer 2: Character Sprite and Floating Dialogue
                if let scene = controller.currentScene {
                    ZStack {
                        // Character Sprite (positioned on left, clipped to screen height)
                        if let sprite = scene.characterSprite {
                            HStack {
                                CharacterSpriteView(
                                    spriteName: sprite,
                                    position: scene.spritePosition ?? .center
                                )
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 1.2)
                                .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.6)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: geometry.size.height, alignment: .bottom)
                            .clipped()
                            .padding(.leading, 20)
                        }
                        
                        // Floating Dialogue Box (positioned on right)
                        HStack {
                            Spacer()
                                .frame(width: geometry.size.width * 0.25)
                            DialogueTextboxView(
                                characterName: scene.characterName,
                                dialogue: scene.dialogue,
                                typingSpeed: controller.typingSpeed,
                                shouldCompleteTyping: controller.shouldCompleteTyping,
                                maxWidth: geometry.size.width * 0.5 - 32,
                                onTypingComplete: { controller.onTypingComplete() },
                                onTap: { controller.handleDialogueTap() }
                            )
                            .frame(maxWidth: geometry.size.width * 0.5, alignment: .topLeading)
                            .padding(.trailing, 20)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if controller.showError {
                    // Empty state when story fails to load
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("No Story Loaded")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("The story could not be loaded. Please check that the story file exists and is properly formatted.")
                            .font(.body)
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
                
                // Completion Overlay
                if controller.isStoryComplete {
                    CompletionOverlay(onRestart: { controller.resetStory() })
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
            SettingsView()
        }
        .alert("Error", isPresented: $controller.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(controller.errorMessage ?? "An unknown error occurred")
        }
    }
}

#Preview {
    VNSceneView()
}

