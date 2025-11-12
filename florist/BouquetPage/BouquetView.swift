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
        ZStack {
            SpriteView(scene: controller.createGameScene(
                onBookTapped: { showFlowerBook = true }
            ))
                .ignoresSafeArea()

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
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .statusBar(hidden: true)
    }
}

#Preview {
    BouquetView()
}
