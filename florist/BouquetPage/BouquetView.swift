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
    @State private var isHintMinimized: Bool = true

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

                        HintBoxView(
                            characterName: characterName,
                            dialogue: dialogueText,
                            maxWidth: min(400, geometry.size.width - 200),
                            isMinimized: $isHintMinimized
                        )
                        .padding(.trailing, geometry.size.width * 0.05)
                    }
                    .padding(.top, geometry.size.height * 0.08)

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
