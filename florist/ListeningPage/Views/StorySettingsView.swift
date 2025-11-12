//
//  StorySettingsView.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import SwiftUI

struct StorySettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("textSpeed") private var textSpeed: Double = 1.0
    @AppStorage("autoAdvance") private var autoAdvance: Bool = false
    
    // Story controller for reset functionality
    var storyController: StoryController?
    
    // State for confirmation dialog and error handling
    @State private var showResetConfirmation = false
    @State private var showResetError = false
    @State private var resetErrorMessage = ""
    @State private var isResetting = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Display") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Text Speed")
                        Slider(value: $textSpeed, in: 0.5...2.0, step: 0.1)
                            .accessibilityLabel("Text speed")
                            .accessibilityValue("\(textSpeed, specifier: "%.1f") times normal speed")
                        Text("Speed: \(textSpeed, specifier: "%.1f")x")
                            .font(.caption1Gaegu)
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                    }
                }
                
                Section("Playback") {
                    Toggle("Auto-Advance", isOn: $autoAdvance)
                        .accessibilityHint("Automatically advances to the next dialogue after a delay")
                }
                
                // Progress Reset Section
                if storyController != nil {
                    Section {
                        Button(role: .destructive) {
                            showResetConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Restart Story")
                            }
                        }
                        .disabled(isResetting)
                        .accessibilityLabel("Restart story from beginning")
                        .accessibilityHint("Deletes your current progress and starts the story over")
                    } header: {
                        Text("Progress")
                    } footer: {
                        Text("Restarting will delete your current progress but preserve your completion record if you've finished this story before.")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Restart Story?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Restart", role: .destructive) {
                    performReset()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete your current progress and start the story from the beginning. Your completion record will be preserved if you've finished this story before.")
            }
            .alert("Reset Failed", isPresented: $showResetError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(resetErrorMessage)
            }
        }
    }
    
    /// Performs the story reset operation
    private func performReset() {
        guard let controller = storyController else { return }
        
        isResetting = true
        
        Task {
            let error = await controller.resetStoryProgress()
            
            await MainActor.run {
                isResetting = false
                
                if let errorMsg = error {
                    resetErrorMessage = errorMsg
                    showResetError = true
                } else {
                    // Success - dismiss the settings view
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    StorySettingsView()
}
