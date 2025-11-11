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
                // Left side - Title and story info
                VStack(alignment: .leading, spacing: 15) {
                    // Title
                    if let folder = controller.selectedMemoryFolder {
                        Text(folder.title)
                            .font(.title2Gaegu)
                            .foregroundColor(.black)
                        
                        Text("Completed: \(formattedDate(story.completionDate))")
                            .font(.custom("Arial", size: 14))
                            .foregroundColor(.gray)
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
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(chapter.title)
                    .font(.headlineGaegu)
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
