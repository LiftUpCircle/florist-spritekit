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
                            .font(.title2Gaegu)
                            .foregroundColor(.black)
                    }
                    
                    // Memory list (formerly chapter list)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(controller.currentMemories) { memory in
                                MemoryButton(
                                    memory: memory,
                                    isSelected: controller.selectedMemory?.id == memory.id
                                ) {
                                    controller.selectMemory(memory)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(width: 220)

                // Right side - Memory details
                if let selectedMemory = controller.selectedMemory {
                    ChapterDetailView(memory: selectedMemory)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.trailing, 20)
                } else {
                    VStack {
                        Text("Select a memory")
                            .font(.headlineGaegu)
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

// Memory Button
struct MemoryButton: View {
    let memory: MemoriesModel.Memory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(memory.title)
                    .font(.headlineGaegu)
                    .foregroundColor(isSelected ? .white : .black)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                Spacer()

                // Indicator if bouquet is saved
                if memory.savedBouquet != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .padding(.trailing, 10)
                }
            }
            .frame(width: 200)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.6) : Color.gray.opacity(0.2))
            )
        }
    }
}

// Backward compatibility alias
typealias ChapterButton = MemoryButton

#Preview {
    let controller = MemoriesViewController()
    controller.selectedMemoryFolder = controller.model.memoryFolders[0]
    controller.showChapterList = true
    controller.selectedMemory = controller.model.memoryFolders[0].memories[0]

    return ChapterListView(controller: controller)
}
