//
//  BouquetPageWrapper.swift
//  florist
//
//  Created by reynaldo on 04/11/25.
//

import SwiftUI

struct BouquetPageWrapper: View {
    let storyId: String
    @ObservedObject var flowCoordinator: GameFlowCoordinator

    var body: some View {
        let requirements = StoryRequirementsDatabase.shared.getRequirements(for: storyId)
        print("🎯 BouquetPageWrapper loading requirements for storyId: '\(storyId)'")
        if let req = requirements {
            print("   ✓ Found requirements with hint: '\(req.hintText)'")
            print("   ✓ Requirements count: \(req.requirements.count)")
        } else {
            print("   ✗ No requirements found!")
        }

        return BouquetView(
            storyRequirements: requirements,
            storyId: storyId, // Pass storyId for saving to memories
            onBouquetComplete: {
                // Trigger completion (will show toast and auto-continue)
                flowCoordinator.onBouquetComplete()
            }
        )
        .navigationBarHidden(true)
        .toast(
            isShowing: $flowCoordinator.showBouquetSavedToast,
            message: flowCoordinator.toastMessage,
            icon: "book.closed.fill",
            duration: 2.0
        )
        .onReceive(NotificationCenter.default.publisher(for: .settingsOverlayDidTapHomeButton)) { _ in
            // Handle notification for navigation to main menu
            flowCoordinator.returnToMainMenu()
        }
    }
}
