//
//  Settings.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("textSpeed") private var textSpeed: Double = 1.0
    @AppStorage("autoAdvance") private var autoAdvance: Bool = false
    
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
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                    }
                }
                
                Section("Playback") {
                    Toggle("Auto-Advance", isOn: $autoAdvance)
                        .accessibilityHint("Automatically advances to the next dialogue after a delay")
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
        }
    }
}

#Preview {
    SettingsView()
}
