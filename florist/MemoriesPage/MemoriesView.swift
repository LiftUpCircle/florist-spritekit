//
//  MemoriesView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 02/11/25.
//

import SwiftUI
import SwiftData

struct MemoriesView: View {
    @StateObject private var controller = MemoriesViewController()
    @Query(sort: \CompletedStory.completionDate, order: .reverse) private var completedStories: [CompletedStory]

    var body: some View {
        ZStack {
            if controller.showChapterList {
                ChapterListView(
                    controller: controller,
                    completedStories: completedStories
                )
            } else {
                MemoryFolderSelectionView(
                    controller: controller,
                    completedStories: completedStories
                )
            }
        }
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Memory Folder Selection View
struct MemoryFolderSelectionView: View {
    @ObservedObject var controller: MemoriesViewController
    let completedStories: [CompletedStory]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Main content
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                // Title
                Text("Memories")
                    .font(.largeTitleGaegu)
                    .foregroundColor(.black)
                
                // Display completed stories or placeholder
                if completedStories.isEmpty {
                    Text("No completed stories yet")
                        .font(.custom("Arial Rounded MT Bold", size: 24))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(completedStories) { story in
                                CompletedStoryCard(story: story) {
                                    controller.selectCompletedStory(story)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.top, 50)
            .padding(.horizontal, 90)
            
            CustomBackButton {
                dismiss()
            }
            .padding(.top, 25)
            .padding(.leading, 35)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Completed Story Card
struct CompletedStoryCard: View {
    let story: CompletedStory
    let action: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: story.completionDate)
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 175, height: 87)
                    .overlay(
                        Image("PlaceholderMemories")
                            .resizable()
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.storyTitle)
                        .font(.custom("Arial Rounded MT Bold", size: 16))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    Text("Completed: \(formattedDate)")
                        .font(.custom("Arial", size: 12))
                        .foregroundColor(.gray)
                }
                .frame(width: 175, alignment: .leading)
            }
        }
    }
}

// MARK: - Custom Back Button
struct CustomBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .font(.title3Gaegu)
                Text("Back")
                    .font(.title3Gaegu)
            }
            .foregroundColor(.black)
        }
    }
}

#Preview {
    MemoriesView()
}
