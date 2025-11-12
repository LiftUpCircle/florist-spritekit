//
//  StoryCompletionDialog.swift
//  florist
//
//  Created by reynaldo on 12/11/25.
//

import SwiftUI

struct StoryCompletionDialog: View {
    let storyId: String
    let hasMoreStories: Bool
    let onContinue: () -> Void
    let onReturnToMenu: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)

            // Dialog card
            VStack(spacing: 25) {
                // Title
                Text("Story Complete!")
                    .font(.title2Gaegu)
                    .foregroundColor(.black)

                // Message
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)

                    Text("You've created a beautiful bouquet!")
                        .font(.headlineGaegu)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text("Your arrangement has been saved to memories.")
                        .font(.bodyGaegu)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 10)

                // Buttons
                VStack(spacing: 15) {
                    if hasMoreStories {
                        // Continue button
                        Button(action: onContinue) {
                            HStack {
                                Text("Continue to Next Story")
                                    .font(.headlineGaegu)
                                    .foregroundColor(.white)
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green)
                            )
                        }
                    }

                    // Return to menu button
                    Button(action: onReturnToMenu) {
                        Text("Return to Main Menu")
                            .font(.headlineGaegu)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.blue)
                            )
                    }
                }
            }
            .padding(30)
            .frame(maxWidth: 400)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 20)
            )
            .padding(40)
        }
    }
}

#Preview {
    StoryCompletionDialog(
        storyId: "story_alice_1",
        hasMoreStories: true,
        onContinue: { print("Continue") },
        onReturnToMenu: { print("Return") }
    )
}
