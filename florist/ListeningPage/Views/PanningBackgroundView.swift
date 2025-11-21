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
            if let uiImage = UIImage(named: imageName) {
                let imageAspectRatio = uiImage.size.width / uiImage.size.height
                let screenHeight = geometry.size.height
                let calculatedImageWidth = screenHeight * imageAspectRatio
                let screenWidth = geometry.size.width

                // Calculate how much extra width we have beyond the screen
                let extraWidth = calculatedImageWidth - screenWidth

                // Position the image so it starts aligned to the left edge of the screen
                HStack(spacing: 0) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: calculatedImageWidth, height: screenHeight)
                }
                .frame(width: screenWidth, height: screenHeight, alignment: .leading)
                .offset(x: offset)
                .clipped()
                .onAppear {
                    startPanning(extraWidth: extraWidth)
                }
            } else {
                // Fallback if image not found
                Color.black
            }
        }
    }

    private func startPanning(extraWidth: CGFloat) {
        // Only pan if there's extra width to show
        guard extraWidth > 0 else { return }

        // Pan from 0 (showing leftmost) to -extraWidth (showing rightmost)
        withAnimation(
            .linear(duration: 20.0)
            .repeatForever(autoreverses: true)
        ) {
            offset = -extraWidth
        }
    }
}

#Preview {
    PanningBackgroundView(imageName: "BackgroundPrologue")
}
