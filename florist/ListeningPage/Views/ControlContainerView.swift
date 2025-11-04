//
//  ControlContainerView.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import SwiftUI

struct ControlContainerView: View {
    let onSettingsTap: () -> Void
    let onLogTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onSettingsTap) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
            .accessibilityLabel("Settings")
            .accessibilityHint("Opens settings to adjust text speed and auto-advance options")
            
            Button(action: onLogTap) {
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
            .accessibilityLabel("Dialogue History")
            .accessibilityHint("Opens a list of all previous dialogue in the story")
        }
    }
}

#Preview {
    ControlContainerView(
        onSettingsTap: { print("Settings tapped") },
        onLogTap: { print("Log tapped") }
    )
    .padding()
    .background(Color.gray)
}
