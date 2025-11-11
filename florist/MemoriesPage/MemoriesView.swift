//
//  MemoriesView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 02/11/25.
//

import SwiftUI

struct MemoriesView: View {
    @StateObject private var controller = MemoriesViewController()

    var body: some View {
        ZStack {
            if controller.showChapterList {
                ChapterListView(controller: controller)
            } else {
                MemoryFolderSelectionView(controller: controller)
            }
        }
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Memory Folder Selection View
struct MemoryFolderSelectionView: View {
    @ObservedObject var controller: MemoriesViewController
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Main content
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                // Title
                Text("Memories")
                    .font(.custom("Gaegu-Bold", size: 40))
                    .foregroundColor(.black)
                
                // Memory cards
                HStack(spacing: 20) {
                    ForEach(controller.model.memoryFolders) { folder in
                        MemoryFolderCard(folder: folder) {
                            controller.selectMemoryFolder(folder)
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

// MARK: - Memory Folder Card
struct MemoryFolderCard: View {
    let folder: MemoriesModel.MemoryFolder
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width:175, height: 87)
                .overlay(
                    Image("PlaceholderMemories")
                        .resizable()
                )
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
                    .font(.system(size: 24))
                Text("Back")
                    .font(.custom("Gaegu-Bold", size: 24))
            }
            .foregroundColor(.black)
        }
    }
}

#Preview {
    MemoriesView()
}
