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
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.characterName)
                                .font(.headline)
                            Text(entry.dialogue)
                                .font(.body)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(entry.characterName) said: \(entry.dialogue)")
                    }
                }
                .padding()
            }
            .accessibilityLabel("Dialogue history list")
            .navigationTitle("Dialogue History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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
