//
//  ChapterDetailView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 02/11/25.
//

import SwiftUI

struct ChapterDetailView: View {
    let memory: MemoriesModel.Memory

    // Backward compatibility
    init(chapter: MemoriesModel.Memory) {
        self.memory = chapter
    }

    init(memory: MemoriesModel.Memory) {
        self.memory = memory
    }

    var body: some View {
        HStack(alignment: .top, spacing: 40) {
            VStack {
                // Bouquet image preview
                Group {
                    if let savedBouquet = memory.savedBouquet,
                       let bouquetImage = BouquetImageManager.shared.loadBouquetImage(filename: savedBouquet.imageFileName) {
                        // Display the actual saved bouquet image
                        Image(uiImage: bouquetImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 190, height: 120)
                            .background(Color.white)
                            .cornerRadius(8)
                    } else {
                        // Placeholder when no bouquet is saved
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 190, height: 120)
                            .cornerRadius(8)
                            .overlay(
                                Text("No saved bouquet")
                                    .font(.bodyGaegu)
                                    .foregroundColor(.gray.opacity(0.7))
                            )
                    }
                }

                // Display date if bouquet exists
                if let savedBouquet = memory.savedBouquet {
                    Text("Saved: \(formattedDate(savedBouquet.dateCreated))")
                        .font(.footnoteGaegu)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }

            Text(memory.description)
                .font(.headlineGaegu)
                .foregroundColor(.black)
                .lineSpacing(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 40)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.5))
    }

    /// Format date for display
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ChapterDetailView(
        memory: MemoriesModel.Memory(
            id: UUID(),
            storyId: "preview_story",
            title: "Preview Memory",
            description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500",
            savedBouquet: nil
        )
    )
}
