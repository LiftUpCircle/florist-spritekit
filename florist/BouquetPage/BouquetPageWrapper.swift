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
        BouquetView(
            storyRequirements: StoryRequirementsDatabase.shared.getRequirements(for: storyId),
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
    }
}
