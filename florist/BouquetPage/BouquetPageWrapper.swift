//
//  BouquetPageWrapper.swift
//  florist
//
//  Created by AI on 04/11/25.
//

import SwiftUI

struct BouquetPageWrapper: View {
    let storyId: String
    @ObservedObject var flowCoordinator: GameFlowCoordinator
    
    var body: some View {
        BouquetView(
            storyRequirements: StoryRequirementsDatabase.shared.getRequirements(for: storyId),
            onBouquetComplete: {
                // Navigate to next story
                flowCoordinator.onBouquetComplete()
            }
        )
        .navigationBarHidden(true)
    }
}
