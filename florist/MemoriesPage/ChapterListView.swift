//
//  ChapterListView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 02/11/25.
//

import SwiftUI

struct ChapterListView: View {
    @ObservedObject var controller: MemoriesViewController
    let completedStories: [CompletedStory]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Main content
            HStack(alignment: .top, spacing: 30) {
                // Left side - Chapter list
                VStack(alignment: .leading, spacing: 15) {
                    // Title
                    if let folder = controller.selectedMemoryFolder {
                        Text(folder.title)
                            .font(.title2Gaegu)
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                        
                        // List of completed stories
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(completedStories, id: \.storyId) { story in
                                    ChapterButton(
                                        story: story,
                                        isSelected: controller.selectedCompletedStory?.storyId == story.storyId
                                    ) {
                                        controller.selectCompletedStory(story)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: 220)
                
                // Right side - Dialogue history
                if let story = controller.selectedCompletedStory {
                    ArchivedDialogueView(dialogueHistory: story.archivedDialogueHistory)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.trailing, 20)
                } else {
                    VStack {
                        Text("Select a chapter")
                            .font(.headlineGaegu)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.top, 70)
            .padding(.leading, 20)
            
            // Back button - fixed at top-left
            CustomBackButton {
                controller.backToFolderSelection()
            }
            .padding(.top, 25)
            .padding(.leading, 35)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Chapter Button

struct ChapterButton: View {
    let story: CompletedStory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(story.storyTitle)
                    .font(.headlineGaegu)
                    .foregroundColor(isSelected ? .white : .black)
                
                Text("Completed: \(formattedDate)")
                    .font(.custom("Arial", size: 12))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(width: 200, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.6) : Color.gray.opacity(0.2))
            )
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: story.completionDate)
    }
}

#Preview {
    let controller = MemoriesViewController()
    let sampleStory = CompletedStory(
        storyId: "story_1",
        completionDate: Date(),
        storyTitle: "A Shy Scholar",
        archivedDialogueHistory: []
    )
    controller.selectedCompletedStory = sampleStory
    controller.showChapterList = true

    return ChapterListView(controller: controller, completedStories: [sampleStory])
}
