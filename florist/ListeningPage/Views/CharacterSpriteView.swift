//
//  CharacterSpriteView.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import SwiftUI

struct CharacterSpriteView: View {
    let spriteName: String
    let position: StoryScene.SpritePosition
    
    /// Check if the image exists in the asset catalog
    private var imageExists: Bool {
        UIImage(named: spriteName) != nil
    }
    
    var body: some View {
        Group {
            if imageExists {
                Image(spriteName)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel("Character sprite")
                    .accessibilityHidden(true)
            } else {
                // Fallback placeholder for missing character sprite
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray.opacity(0.5))
                    .accessibilityLabel("Character sprite placeholder")
                    .accessibilityHidden(true)
                    .onAppear {
                        print("⚠️ Warning: Character sprite '\(spriteName)' not found in asset catalog")
                    }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        CharacterSpriteView(
            spriteName: "character_happy",
            position: .center
        )
    }
}
