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
        ZStack {
            BouquetView(
                storyRequirements: StoryRequirementsDatabase.shared.getRequirements(for: storyId),
                storyId: storyId, // Pass storyId for saving to memories
                onBouquetComplete: {
                    // Trigger completion (will show dialog)
                    flowCoordinator.onBouquetComplete()
                }
            )
            .navigationBarHidden(true)

            // Show completion dialog overlay
            if flowCoordinator.showCompletionDialog {
                StoryCompletionDialog(
                    storyId: storyId,
                    hasMoreStories: GameProgressManager.shared.hasMoreStories,
                    onContinue: {
                        flowCoordinator.continueToNextStory()
                    },
                    onReturnToMenu: {
                        flowCoordinator.returnToMainMenu()
                    }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
    }
}
