//
//  ChapterDetailView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 02/11/25.
//

import SwiftUI

struct ChapterDetailView: View {
    let chapter: MemoriesModel.Chapter

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Chapter title at the top
            Text(chapter.title)
                .font(.custom("Arial Rounded MT Bold", size: 40))
                .foregroundColor(.black)
                .padding(.top, 80)

            HStack(alignment: .top, spacing: 40) {
                // Saved bouquet image (if available)
                if let savedBouquet = chapter.savedBouquet {
                    VStack {
                        // Placeholder for bouquet image
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 300, height: 300)
                            .cornerRadius(15)
                            .overlay(
                                // Try to load the image, or show placeholder
                                Image(systemName: "photo")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                            )

                        Text("Saved: \(formattedDate(savedBouquet.dateCreated))")
                            .font(.custom("Arial Rounded MT Bold", size: 16))
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                } else {
                    // No saved bouquet placeholder
                    VStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 300, height: 300)
                            .cornerRadius(15)
                            .overlay(
                                VStack(spacing: 10) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("No saved bouquet")
                                        .font(.custom("Arial Rounded MT Bold", size: 16))
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                            )
                    }
                }

                // Chapter description
                Text(chapter.description)
                    .font(.custom("Arial", size: 20))
                    .foregroundColor(.black)
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 40)
            }
            .padding(.leading, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    ChapterDetailView(
        chapter: MemoriesModel.Chapter(
            title: "A Shy Scholar",
            description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500",
            savedBouquet: MemoriesModel.SavedBouquet(
                imageName: "sample_bouquet",
                dateCreated: Date()
            )
        )
    )
}
