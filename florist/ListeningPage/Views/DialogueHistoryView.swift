//
//  DialogueHistoryView.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import SwiftUI

struct DialogueHistoryView: View {
    @Environment(\.dismiss) var dismiss
    let entries: [DialogueEntry]

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            Color("DialogueTextbox")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Conversation History")
                        .font(.title2Gaegu)
                        .foregroundColor(.black)
                        .padding(.leading, 20)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 50)
                .padding(.bottom, 20)

                // Scrollable dialogue history
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(entries) { entry in
                            HistoryDialogueBox(
                                characterName: entry.characterName,
                                dialogue: entry.dialogue
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// History dialogue box without the triangle indicator
struct HistoryDialogueBox: View {
    let characterName: String
    let dialogue: String

    // Display name with "(you)" indicator for Maria
    private var displayName: String {
        if characterName.lowercased().contains("maria") {
            return "\(characterName) (you)"
        }
        return characterName
    }

    // Check if this is Maria's dialogue
    private var isMaria: Bool {
        characterName.lowercased().contains("maria")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(displayName)
                .font(.bodyGaegu)
                .fontWeight(.semibold)
                .foregroundColor(isMaria ? .white : .primary)

            Text(dialogue)
                .font(.bodyGaegu)
                .foregroundColor(isMaria ? .white : .primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isMaria ? Color("DialogueTextboxBorder") : Color("DialogueTextbox"))
                .stroke(isMaria ? Color("DialogueTextbox") : Color("DialogueTextboxBorder"), lineWidth: 5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(characterName) said: \(dialogue)")
    }
}

#Preview {
    DialogueHistoryView(entries: [
        DialogueEntry(
            id: UUID(),
            characterName: "Alice",
            dialogue: "Hello! Welcome to our story.",
            timestamp: Date()
        ),
        DialogueEntry(
            id: UUID(),
            characterName: "Bob",
            dialogue: "Thanks for having me!",
            timestamp: Date()
        ),
        DialogueEntry(
            id: UUID(),
            characterName: "Narrator",
            dialogue: "And so the adventure begins...",
            timestamp: Date()
        )
    ])
}
