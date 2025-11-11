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
        ZStack(alignment: .topLeading) {
            // Main content
            HStack(alignment: .top, spacing: 30) {
                // Left side - Title and chapter list
                VStack(alignment: .leading, spacing: 15) {
                    // Title
                    if let folder = controller.selectedMemoryFolder {
                        Text(folder.title)
                            .font(.custom("Gaegu-Bold", size: 28))
                            .foregroundColor(.black)
                    }
                    
                    // Chapter list
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(controller.currentChapters) { chapter in
                                ChapterButton(
                                    chapter: chapter,
                                    isSelected: controller.selectedChapter?.id == chapter.id
                                ) {
                                    controller.selectChapter(chapter)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(width: 220)
                
                // Right side - Chapter details
                if let selectedChapter = controller.selectedChapter {
                    ChapterDetailView(chapter: selectedChapter)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.trailing, 20)
                } else {
                    VStack {
                        Text("Select a chapter")
                            .font(.custom("Gaegu-Bold", size: 18))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.top, 70) // Reduced from 120
            .padding(.leading, 20) // Reduced from 120
            
            // Back button - fixed at top-left
            CustomBackButton {
                controller.backToFolderSelection()
            }
            .padding(.top, 25) // Reduced from 20
            .padding(.leading, 35) // Reduced from 20
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.all)
    }
}

// Updated ChapterButton
struct ChapterButton: View {
    let chapter: MemoriesModel.Chapter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(chapter.title)
                    .font(.custom("Gaegu-Bold", size: 18))
                    .foregroundColor(isSelected ? .white : .black)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                Spacer()
            }
            .frame(width: 200)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.6) : Color.gray.opacity(0.2))
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
