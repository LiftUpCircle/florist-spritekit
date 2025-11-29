//
//  FallingPetalsView.swift
//  florist
//
//  Created by reynaldo
//

import SwiftUI

struct FallingPetalsView: View {
    @State private var petals: [FallingPetal] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(petals) { petal in
                    Image(petal.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: petal.size, height: petal.size)
                        .rotationEffect(.degrees(petal.rotation))
                        .opacity(petal.opacity)
                        .position(x: petal.x, y: petal.y)
                }
            }
            .onAppear {
                startPetalAnimation(in: geometry)
            }
        }
        .allowsHitTesting(false) // Allow touches to pass through to buttons below
    }

    private func startPetalAnimation(in geometry: GeometryProxy) {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height

        // Start with larger initial batch of petals at random positions
        for _ in 0..<25 {
            let delay = Double.random(in: 0...3)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                spawnPetal(screenWidth: screenWidth, screenHeight: screenHeight)
            }
        }

        // Continuously spawn new petals more frequently
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            spawnPetal(screenWidth: screenWidth, screenHeight: screenHeight)
        }
    }

    private func spawnPetal(screenWidth: CGFloat, screenHeight: CGFloat) {
        let petalNumber = Int.random(in: 1...5)
        // Spawn across entire screen width to ensure right side coverage
        let startX = CGFloat.random(in: -100...(screenWidth + 100))
        let startY: CGFloat = -50 // Start above screen

        let petal = FallingPetal(
            imageName: "petal\(petalNumber)",
            x: startX,
            y: startY,
            size: CGFloat.random(in: 10...25), // Much smaller petals
            rotation: Double.random(in: 0...360),
            opacity: Double.random(in: 0.5...0.85)
        )

        petals.append(petal)

        // Animate the petal falling faster with realistic wind from left
        let duration = Double.random(in: 4...8) // Faster fall
        let endY = screenHeight + 100 // End below screen

        // Realistic wind effect from left - stronger drift with variation
        let baseWindStrength = CGFloat.random(in: 120...250)
        let windVariation = CGFloat.random(in: -30...50) // Some turbulence
        let horizontalDrift = baseWindStrength + windVariation

        let rotationAmount = Double.random(in: -900...900) // More rotation for realism

        withAnimation(
            .easeInOut(duration: duration) // Easing for more natural movement
        ) {
            if let index = petals.firstIndex(where: { $0.id == petal.id }) {
                petals[index].y = endY
                petals[index].x = startX + horizontalDrift
                petals[index].rotation = petal.rotation + rotationAmount
            }
        }

        // Remove petal after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) {
            petals.removeAll { $0.id == petal.id }
        }
    }
}

// MARK: - Falling Petal Model

struct FallingPetal: Identifiable {
    let id = UUID()
    let imageName: String
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var rotation: Double
    let opacity: Double
}

#Preview {
    ZStack {
        Color.blue.opacity(0.3)
            .ignoresSafeArea()

        FallingPetalsView()
    }
}
