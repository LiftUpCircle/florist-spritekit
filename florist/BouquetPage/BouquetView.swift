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

                VStack {
                    HStack {
                        Spacer()

                        DialogueTextboxView(
                            characterName: characterName,
                            dialogue: dialogueText,
                            typingSpeed: 0.03,
                            shouldCompleteTyping: false,
                            maxWidth: min(400, geometry.size.width - 200),
                            onTypingComplete: {},
                            onTap: {}
                        )
                        .padding(.trailing, 100)
                    }
                    .padding(.top, 20)

                    Spacer()
                }

                // Flower Book Modal
                if showFlowerBook {
                    FlowerBookView(onDismiss: {
                        withAnimation {
                            showFlowerBook = false
                        }
                    })
                    .transition(.opacity)
                    .zIndex(1)
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
