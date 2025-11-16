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
        VStack(spacing: 12) {
            Button(action: onLogTap) {
                Image("ConversationLogButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
            .accessibilityLabel("Conversation History")
            .accessibilityHint("Opens a list of all previous dialogue in the story")

            Button(action: onSettingsTap) {
                Image("SettingButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
            .accessibilityLabel("Settings")
            .accessibilityHint("Opens settings menu")
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
