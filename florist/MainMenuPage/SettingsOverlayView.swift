//
//  SettingsOverlayView.swift
//  florist
//
//  Created by AI Assistant on 05/11/25.
//

import SwiftUI
import SpriteKit

// MARK: - Settings Scene
class SettingsScene: SKScene, SettingsOverlayControllerDelegate {
    private var settingsOverlayController: SettingsOverlayController?
    var onDismiss: (() -> Void)?

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // Set background color
        backgroundColor = SKColor.clear

        // Show settings overlay immediately
        settingsOverlayController = SettingsOverlayController(scene: self)
        settingsOverlayController?.delegate = self
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if let controller = settingsOverlayController {
            controller.handleTouchBegan(touch)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if let controller = settingsOverlayController {
            controller.handleTouchMoved(touch)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if let controller = settingsOverlayController {
            controller.handleTouchEnded(touch)
        }
    }

    // MARK: - SettingsOverlayControllerDelegate
    func settingsOverlayDidClose() {
        onDismiss?()
    }

    func settingsOverlayDidTapRateGame() {
        // Handle rate game
        if let url = URL(string: "https://apps.apple.com/app/idXXXXXXXXX") {
            UIApplication.shared.open(url)
        }
    }

    func settingsOverlayDidTapSubscriptions() {
        // Handle subscriptions
        print("Subscriptions tapped")
    }

    func settingsOverlayDidTapContactUs() {
        // Handle contact us
        if let url = URL(string: "mailto:support@floristgame.com") {
            UIApplication.shared.open(url)
        }
    }

    func settingsOverlayDidTapPrivacy() {
        // Handle privacy
        if let url = URL(string: "https://floristgame.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - SwiftUI View Wrapper
struct SettingsOverlayView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: createSettingsScene(size: geometry.size))
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }

    private func createSettingsScene(size: CGSize) -> SettingsScene {
        let scene = SettingsScene(size: size)
        scene.scaleMode = .aspectFill
        scene.onDismiss = {
            dismiss()
        }
        return scene
    }
}

#Preview {
    SettingsOverlayView()
}