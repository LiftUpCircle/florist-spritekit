//
//  BouquetView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import SwiftUI
import SpriteKit

struct BouquetView: View {
    var storyRequirements: StoryFlowerRequirements?
    var storyId: String?
    var onBouquetComplete: (() -> Void)?

    @StateObject private var controller: BouquetViewController
    @State private var showFlowerBook = false
    @State private var dialogueText: String = ""
    @State private var characterName: String = "Hint"
    @State private var isHintMinimized: Bool = false  // Default to expanded
    @State private var isPulsing: Bool = false

    init(storyRequirements: StoryFlowerRequirements? = nil, storyId: String? = nil, onBouquetComplete: (() -> Void)? = nil) {
        self.storyRequirements = storyRequirements
        self.storyId = storyId
        self.onBouquetComplete = onBouquetComplete

        // Initialize controller with requirements and storyId
        _controller = StateObject(wrappedValue: BouquetViewController(
            storyRequirements: storyRequirements,
            storyId: storyId,
            onBouquetComplete: onBouquetComplete
        ))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SpriteView(scene: controller.createGameScene(
                    onBookTapped: { showFlowerBook = true }
                ))
                    .ignoresSafeArea()
                    .zIndex(controller.isSettingsOpen ? 2 : 0)

                VStack {
                    HStack {
                        Spacer()

                        if isHintMinimized {
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isHintMinimized = false
                                    isPulsing = false
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.bodyGaegu)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("DialogueTextboxBorder"))

                                    Text("Hint")
                                        .font(.bodyGaegu)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color("DialogueTextbox"))
                                        .stroke(Color("DialogueTextboxBorder"), lineWidth: 5)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(isPulsing ? 1.05 : 1.0)
                            .padding(.trailing, 20)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                    isPulsing = true
                                }
                            }
                        } else {
                            
                            ZStack(alignment: .topTrailing) {
                                DialogueTextboxView(
                                    characterName: characterName,
                                    dialogue: dialogueText,
                                    typingSpeed: 0.03,
                                    shouldCompleteTyping: false,
                                    maxWidth: min(400, geometry.size.width - 200),
                                    showTriangleIndicator: false,
                                    onTypingComplete: {},
                                    onTap: {}
                                )


                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isHintMinimized = true
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(Color("DialogueTextboxBorder"))
                                        .background(
                                            Circle()
                                                .fill(Color("DialogueTextbox"))
                                                .frame(width: 26, height: 26)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .offset(x: -10, y: 10)
                            }
                            .padding(.trailing, 20)  // Same padding as minimized state
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }
                    }
                    .padding(.top, 20)

                    Spacer()
                }
                .zIndex(1)

                // Flower Book Modal
                if showFlowerBook {
                    FlowerBookView(onDismiss: {
                        withAnimation {
                            showFlowerBook = false
                        }
                    })
                    .transition(.opacity)
                    .zIndex(999)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .statusBar(hidden: true)
        .onAppear {
            dialogueText = storyRequirements?.hintText ?? "Drag flowers to create your bouquet"
        }
    }
}

#Preview {
    BouquetView()
}
