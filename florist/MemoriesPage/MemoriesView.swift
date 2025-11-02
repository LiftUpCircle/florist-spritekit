//
//  MemoriesView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 02/11/25.
//

import SwiftUI

struct MemoriesView: View {
    @StateObject private var controller = MemoriesViewController()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color(red: 0.85, green: 0.85, blue: 0.87)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if controller.showChapterList {
                // Chapter list view with detail
                ChapterListView(controller: controller)
            } else {
                // Memory folder selection view
                MemoryFolderSelectionView(controller: controller)
            }
        }
        .navigationBarHidden(false)
    }
}

// MARK: - Memory Folder Selection View
struct MemoryFolderSelectionView: View {
    @ObservedObject var controller: MemoriesViewController
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Custom back button
            CustomBackButton {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.leading, 40)
            .padding(.top, 40)

            // Title
            Text("Memories")
                .font(.custom("Arial Rounded MT Bold", size: 60))
                .foregroundColor(.black)
                .padding(.leading, 100)
                .padding(.top, 20)

            // 3 Memory Folders
            HStack(spacing: 30) {
                ForEach(controller.model.memoryFolders) { folder in
                    MemoryFolderCard(folder: folder) {
                        controller.selectMemoryFolder(folder)
                    }
                }
            }
            .padding(.horizontal, 100)
            .padding(.top, 40)

            Spacer()
        }
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
                .frame(height: 250)
                .overlay(
                    Text(folder.title)
                        .font(.custom("Arial Rounded MT Bold", size: 24))
                        .foregroundColor(.black)
                )
                .cornerRadius(15)
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
                    .font(.custom("Arial Rounded MT Bold", size: 24))
            }
            .foregroundColor(.black)
        }
    }
}

#Preview {
    MemoriesView()
}
