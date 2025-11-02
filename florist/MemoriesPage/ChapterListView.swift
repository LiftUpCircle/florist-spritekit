//
//  ChapterListView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 02/11/25.
//

import SwiftUI

struct ChapterListView: View {
    @ObservedObject var controller: MemoriesViewController

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left side - Chapter list (5 vertical chapters)
            VStack(alignment: .leading, spacing: 20) {
                // Custom back button
                CustomBackButton {
                    controller.backToFolderSelection()
                }
                .padding(.leading, 40)
                .padding(.top, 40)

                // Memory folder title
                if let folder = controller.selectedMemoryFolder {
                    Text(folder.title)
                        .font(.custom("Arial Rounded MT Bold", size: 50))
                        .foregroundColor(.black)
                        .padding(.leading, 100)
                        .padding(.top, 20)
                }

                // Chapter buttons (vertically stacked)
                VStack(spacing: 15) {
                    ForEach(controller.currentChapters) { chapter in
                        ChapterButton(
                            chapter: chapter,
                            isSelected: controller.selectedChapter?.id == chapter.id
                        ) {
                            controller.selectChapter(chapter)
                        }
                    }
                }
                .padding(.leading, 100)
                .padding(.top, 30)

                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width * 0.4)

            // Right side - Chapter detail
            if let selectedChapter = controller.selectedChapter {
                ChapterDetailView(chapter: selectedChapter)
                    .frame(width: UIScreen.main.bounds.width * 0.6)
            } else {
                // Placeholder when no chapter is selected
                VStack {
                    Text("Select a chapter to view details")
                        .font(.custom("Arial Rounded MT Bold", size: 28))
                        .foregroundColor(.gray)
                }
                .frame(width: UIScreen.main.bounds.width * 0.6)
            }
        }
    }
}

// MARK: - Chapter Button
struct ChapterButton: View {
    let chapter: MemoriesModel.Chapter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(chapter.title)
                    .font(.custom("Arial Rounded MT Bold", size: 22))
                    .foregroundColor(isSelected ? .white : .black)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2))
            )
        }
    }
}

#Preview {
    let controller = MemoriesViewController()
    controller.selectedMemoryFolder = controller.model.memoryFolders[0]
    controller.showChapterList = true
    controller.selectedChapter = controller.model.memoryFolders[0].chapters[0]

    return ChapterListView(controller: controller)
}
