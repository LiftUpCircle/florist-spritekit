//
//  ArchivedDialogueHistoryView.swift
//  florist
//
//  View for displaying archived dialogue history from completed stories
//

import SwiftUI

struct ArchivedDialogueView: View {
    let dialogueHistory: [DialogueHistoryEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Story Dialogue")
                .font(.custom("Arial Rounded MT Bold", size: 20))
                .foregroundColor(.black)
                .padding(.bottom, 5)
            
            if dialogueHistory.isEmpty {
                Text("No dialogue history available")
                    .font(.custom("Arial", size: 16))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(dialogueHistory) { entry in
                            ArchivedDialogueEntryView(entry: entry)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ArchivedDialogueEntryView: View {
    let entry: DialogueHistoryEntry
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.timestamp)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(entry.characterName)
                    .font(.custom("Arial Rounded MT Bold", size: 16))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text(formattedTime)
                    .font(.custom("Arial", size: 12))
                    .foregroundColor(.gray)
            }
            
            Text(entry.dialogue)
                .font(.custom("Arial", size: 14))
                .foregroundColor(.black.opacity(0.8))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            if !entry.sceneId.isEmpty {
                Text("Scene: \(entry.sceneId)")
                    .font(.custom("Arial", size: 11))
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.6))
        .cornerRadius(8)
    }
}

#Preview {
    ArchivedDialogueView(
        dialogueHistory: [
            DialogueHistoryEntry(
                characterName: "Narrator",
                dialogue: "Welcome to the story...",
                timestamp: Date(),
                sceneId: "scene_1"
            ),
            DialogueHistoryEntry(
                characterName: "Character",
                dialogue: "This is a sample dialogue entry that shows how the archived dialogue will appear in the memories view.",
                timestamp: Date().addingTimeInterval(-300),
                sceneId: "scene_2"
            )
        ]
    )
}
