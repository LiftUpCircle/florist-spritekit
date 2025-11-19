//
//  SettingsOverlayView.swift
//  florist
//
//  Created by reynaldo on 05/11/25.
//

import SwiftUI
import SpriteKit

// MARK: - Settings Scene
class SettingsScene: SKScene, SettingsOverlayControllerDelegate {
    private var settingsOverlayController: SettingsOverlayController?
    var onDismiss: (() -> Void)?
    var onHomeButtonTap: (() -> Void)?

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // Set background to transparent
        backgroundColor = SKColor.clear

        // Make the view transparent
        view.allowsTransparency = true
        view.backgroundColor = .clear

        // Show settings overlay immediately
        settingsOverlayController = SettingsOverlayController(scene: self)
        settingsOverlayController?.delegate = self
        settingsOverlayController?.onHomeButtonTap = { [weak self] in
            self?.onHomeButtonTap?()
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if let controller = settingsOverlayController {
            _ = controller.handleTouchBegan(touch)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if let controller = settingsOverlayController {
            _ = controller.handleTouchMoved(touch)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if let controller = settingsOverlayController {
            _ = controller.handleTouchEnded(touch)
        }
    }

    // MARK: - SettingsOverlayControllerDelegate
    func settingsOverlayDidClose() {
        onDismiss?()
    }
    
    func settingsOverlayDidTapHomeButton() {
        // Call the home button tap closure
        onHomeButtonTap?()
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
    @Binding var isPresented: Bool
    var onHomeButtonTap: (() -> Void)?

    var body: some View {
        GeometryReader { geometry in
            // Settings overlay with transparent background
            SpriteView(
                scene: createSettingsScene(size: geometry.size),
                options: [.allowsTransparency]
            )
            .ignoresSafeArea()
            .allowsHitTesting(true)
            .background(Color.clear)
        }
    }

    private func createSettingsScene(size: CGSize) -> SettingsScene {
        let scene = SettingsScene(size: size)
        scene.scaleMode = .aspectFill
        scene.onDismiss = {
            withAnimation {
                isPresented = false
            }
        }
        scene.onHomeButtonTap = {
            // Close settings first
            withAnimation {
                isPresented = false
            }
            // Then call the navigation closure
            onHomeButtonTap?()
        }
        return scene
    }
}

#Preview {
    @Previewable @State var isPresented = true
    return SettingsOverlayView(isPresented: $isPresented)
}