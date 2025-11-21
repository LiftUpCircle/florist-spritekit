//
//  PanningBackgroundView.swift
//  florist
//
//  Created by reynaldo on 21/11/25.
//

import SwiftUI

struct PanningBackgroundView: View {
    let imageName: String
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width * 1.8) // Make it wider for panning
                .offset(x: offset)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .onAppear {
                    startPanning(screenWidth: geometry.size.width)
                }
        }
    }

    private func startPanning(screenWidth: CGFloat) {
        // Calculate the maximum pan distance
        // The image is 1.8x screen width, so we can pan 0.8x screen width
        let maxPanDistance = screenWidth * 0.8

        // Start from the left (0) and pan to the right (-maxPanDistance)
        // offset of 0 shows the leftmost part
        // offset of -maxPanDistance shows the rightmost part
        withAnimation(
            .linear(duration: 20.0) // Slow smooth pan
            .repeatForever(autoreverses: true)
        ) {
            offset = -maxPanDistance
        }
    }
}

#Preview {
    PanningBackgroundView(imageName: "BackgroundPrologue")
}
