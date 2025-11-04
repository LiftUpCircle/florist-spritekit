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
    var onBouquetComplete: (() -> Void)?
    
    @StateObject private var controller: BouquetViewController
    @State private var showFlowerBook = false
    @State private var showSettings = false
    
    init(storyRequirements: StoryFlowerRequirements? = nil, onBouquetComplete: (() -> Void)? = nil) {
        self.storyRequirements = storyRequirements
        self.onBouquetComplete = onBouquetComplete
        
        // Initialize controller with requirements
        _controller = StateObject(wrappedValue: BouquetViewController(
            storyRequirements: storyRequirements,
            onBouquetComplete: onBouquetComplete
        ))
    }

    var body: some View {
        ZStack {
            SpriteView(scene: controller.createGameScene(
                onBookTapped: { showFlowerBook = true },
                onSettingTapped: { showSettings = true }
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
            
            // Settings Modal
            if showSettings {
                SettingsView(onDismiss: {
                    withAnimation {
                        showSettings = false
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
