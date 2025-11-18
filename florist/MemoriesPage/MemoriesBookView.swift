//
//  MemoriesBookView.swift
//  florist
//
//  Created by Claude on 17/11/25.
//

import SwiftUI

struct MemoriesBookView: View {
    var onDismiss: () -> Void
    @StateObject private var controller = MemoriesViewController()
    @State private var selectedCharacterIndex = 0

    // Character data
    private let characters = [
        CharacterMemory(id: "robert", name: "Robert", imageName: "MemoriesRobert"),
        CharacterMemory(id: "abigail", name: "Abigail", imageName: "MemoriesAbigail"),
        CharacterMemory(id: "michael", name: "Michael", imageName: "MemoriesMichael")
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

                VStack(spacing: 10) {
                    // Memories book
                    ZStack {
                        // Book background
                        Image("MemoriesBook")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: min(geometry.size.width * 0.75, 750),
                                   height: min(geometry.size.height * 0.90, 900))

                        // Book content
                        MemoriesBookContentView(
                            character: characters[selectedCharacterIndex],
                            controller: controller
                        )
                        .frame(width: min(geometry.size.width * 0.75, 750),
                               height: min(geometry.size.height * 0.90, 900))
                    }

                    // Character tabs horizontally at bottom
                    HStack(spacing: 30) {
                        ForEach(Array(characters.enumerated()), id: \.offset) { index, character in
                            CharacterTabButton(
                                characterName: character.name,
                                isSelected: selectedCharacterIndex == index
                            ) {
                                selectedCharacterIndex = index
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            controller.refreshSavedBouquets()
        }
        .statusBar(hidden: true)
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

    // Get memories for the selected character
    private var characterMemories: [MemoriesModel.Memory] {
        controller.model.memoryFolders
            .first(where: { $0.characterName.lowercased().contains(character.name.lowercased()) })?
            .memories ?? []
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left page - Character portrait
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

            // Right page - Bouquet list
            VStack(alignment: .leading, spacing: 6) {
                Text("Bouquets")
                    .font(.bodyGaegu)
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
        }
    }
}

// MARK: - Bouquet Memory Row
struct BouquetMemoryRow: View {
    let memory: MemoriesModel.Memory

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            Text(memory.title)
                .font(.custom("Gaegu-Bold", size: 14))
                .foregroundColor(.black)
                .lineLimit(1)

            // Bouquet image
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

            // Description
            VStack(alignment: .leading, spacing: 2) {
                Text(memory.description)
                    .font(.custom("Gaegu-Regular", size: 12))
                    .foregroundColor(.gray)

                if let savedBouquet = memory.savedBouquet {
                    Text("Created: \(formattedDate(savedBouquet.dateCreated))")
                        .font(.custom("Gaegu-Light", size: 10))
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
