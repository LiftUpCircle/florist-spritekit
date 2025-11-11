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
            HStack(alignment: .top, spacing: 40) {
                    VStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 190, height: 120)
                            .overlay(
                                Group{
                                if chapter.savedBouquet != nil {
                                    Image(systemName: "photo")
                                        .font(.system(size: 80))
                                        .foregroundColor(.gray)

                                }else{
                                    Text("No saved bouquet")
                                        .font(.custom("Gaegu-Bold", size: 16))
                                        .foregroundColor(.gray.opacity(0.7))
                                    }
                                }
                            )
                    }

                Text(chapter.description)
                    .font(.custom("Gaegu-Regular", size: 20))
                    .foregroundColor(.black)
                    .lineSpacing(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 40)
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.5))
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
