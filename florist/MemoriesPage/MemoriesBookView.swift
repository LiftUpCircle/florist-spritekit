//
//  MemoriesBookView.swift
//  florist
//
//  Created by reynaldo on 17/11/25.
//

import SwiftUI

struct MemoriesBookView: View {
    var onDismiss: () -> Void
    @StateObject private var controller = MemoriesViewController()
    @State private var selectedCharacterIndex = 0
    @State private var isAnimating = false

    // Character data
    private let characters = [
        CharacterMemory(id: "robert", name: "Robert", imageName: "MemoriesRobert"),
        CharacterMemory(id: "michael", name: "Michael", imageName: "MemoriesMichael"),
        CharacterMemory(id: "abigail", name: "Abigail", imageName: "MemoriesAbigail")
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }

                // Centered book with arrow buttons
                ZStack {
                    // Book background
                    Image("MemoriesBook")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: min(geometry.size.width * 0.75, 750),
                               height: min(geometry.size.height * 0.90, 900))

                    // Book content with independent transitions for each page
                    if characters.indices.contains(selectedCharacterIndex) {
                        MemoriesBookContentView(
                            character: characters[selectedCharacterIndex],
                            controller: controller
                        )
                        .frame(width: min(geometry.size.width * 0.75, 750),
                               height: min(geometry.size.height * 0.90, 900))
                    }

                    // Navigation arrows
                    HStack {
                        // Previous Button (Left Arrow)
                        if selectedCharacterIndex > 0 {
                            Button(action: {
                                guard !isAnimating else { return }
                                goToPrevious()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 44, height: 44)
                                    )
                            }
                            .disabled(isAnimating)
                            .padding(.leading, 11)
                        }

                        Spacer()

                        // Next Button (Right Arrow)
                        if selectedCharacterIndex < characters.count - 1 {
                            Button(action: {
                                guard !isAnimating else { return }
                                goToNext()
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 44, height: 44)
                                    )
                            }
                            .disabled(isAnimating)
                            .padding(.trailing, 15)
                        }
                    }
                    .frame(width: min(geometry.size.width * 0.65, 650),
                           height: min(geometry.size.height * 0.85, 850))
                }
            }
        }
        .onAppear {
            controller.refreshSavedBouquets()
            // Preload flipping sound
            SettingsManager.shared.preloadSound(named: "flippingbook")
        }
        .statusBar(hidden: true)
    }

    // Helper function to go to previous character
    private func goToPrevious() {
        guard selectedCharacterIndex > 0 else { return }
        isAnimating = true
        playFlippingSound()

        withAnimation(.easeInOut(duration: 0.3)) {
            selectedCharacterIndex -= 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
        }
    }

    // Helper function to go to next character
    private func goToNext() {
        guard selectedCharacterIndex < characters.count - 1 else { return }
        isAnimating = true
        playFlippingSound()

        withAnimation(.easeInOut(duration: 0.3)) {
            selectedCharacterIndex += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimating = false
        }
    }

    // Helper function to play flipping sound
    private func playFlippingSound() {
        print("🎵 Page flip - playing flipping sound")
        SettingsManager.shared.playPageFlip()
    }
}

// MARK: - Character Memory Data
struct CharacterMemory {
    let id: String
    let name: String
    let imageName: String
}

// MARK: - Character Tab Button
struct CharacterTabButton: View {
    let characterName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(characterName)
                .font(.title3Gaegu)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color("BorderInventory") : Color.gray.opacity(0.5))
                )
        }
    }
}

// MARK: - Memories Book Content
struct MemoriesBookContentView: View {
    let character: CharacterMemory
    @ObservedObject var controller: MemoriesViewController
    @EnvironmentObject private var textSizeManager: TextSizeManager

    // Get memories for the selected character
    private var characterMemories: [MemoriesModel.Memory] {
        controller.model.memoryFolders
            .first(where: { $0.characterName.lowercased().contains(character.name.lowercased()) })?
            .memories ?? []
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left page - Character portrait (fade animation only)
            VStack {
                Spacer()

                Image(character.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 220)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.leading, 80)
            .id(character.id) // Force view recreation
            .transition(.opacity) // Fade only for character portrait

            // Right page - Bouquet list (slide animation)
            VStack(alignment: .leading, spacing: 6) {
                Text("Bouquets")
                    .font(.gaeguFont(size: 17, weight: "Bold"))
                    .foregroundColor(.black)
                    .padding(.bottom, 2)

                if characterMemories.isEmpty {
                    VStack {
                        Spacer()
                        Text("No bouquets created yet")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(characterMemories) { memory in
                                BouquetMemoryRow(memory: memory)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: 250, maxHeight: .infinity, alignment: .leading)
            .padding(.leading, 18)
            .padding(.trailing, 80)
            .padding(.vertical, 40)
            .id("\(character.id)_bouquets") // Force view recreation with unique id
            .transition(.opacity.combined(with: .move(edge: .trailing))) // Slide for bouquet list
        }
    }
}

// MARK: - Bouquet Memory Row
struct BouquetMemoryRow: View {
    let memory: MemoriesModel.Memory
    @EnvironmentObject private var textSizeManager: TextSizeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            Text(memory.title)
                .font(.gaeguFont(size: 14, weight: "Bold"))
                .foregroundColor(.black)
                .lineLimit(1)

            // Check if story has been played (savedBouquet exists)
            if memory.savedBouquet != nil {
                // Show bouquet image
                if let savedBouquet = memory.savedBouquet,
                   let bouquetImage = BouquetImageManager.shared.loadBouquetImage(filename: savedBouquet.imageFileName) {
                    Image(uiImage: bouquetImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .cornerRadius(6)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .cornerRadius(6)
                }

                // Show description
                VStack(alignment: .leading, spacing: 2) {
                    Text(memory.description)
                        .font(.gaeguFont(size: 12, weight: "Regular"))
                        .foregroundColor(.gray)

                    if let savedBouquet = memory.savedBouquet {
                        Text("Created: \(formattedDate(savedBouquet.dateCreated))")
                            .font(.gaeguFont(size: 10, weight: "Regular"))
                            .foregroundColor(.gray)
                    }
                }
                .padding(8)
                .frame(width: 175, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
            } else {
                // Story not played yet - show locked state
                VStack {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("Play the story to unlock")
                        .font(.custom("Gaegu-Regular", size: 12))
                        .foregroundColor(.gray)
                }
                .frame(width: 175, height: 150)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.vertical, 4)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    MemoriesBookView(onDismiss: {})
}
