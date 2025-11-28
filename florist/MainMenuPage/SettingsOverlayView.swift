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
    var onResetGameTap: (() -> Void)?
    var isFromMainMenu: Bool = false

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // Set background to transparent
        backgroundColor = SKColor.clear

        // Make the view transparent
        view.allowsTransparency = true
        view.backgroundColor = .clear

        // Show settings overlay immediately
        settingsOverlayController = SettingsOverlayController(scene: self, isFromMainMenu: isFromMainMenu)
        settingsOverlayController?.delegate = self
        settingsOverlayController?.onHomeButtonTap = { [weak self] in
            self?.onHomeButtonTap?()
        }
        settingsOverlayController?.onResetGameTap = { [weak self] in
            self?.onResetGameTap?()
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
// MARK: - SwiftUI View Wrapper
struct SettingsOverlayView: View {
    @Binding var isPresented: Bool
    var onHomeButtonTap: (() -> Void)?
    var onResetGameTap: (() -> Void)?
    var isFromMainMenu: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            SettingsSceneView(
                isPresented: $isPresented,
                onHomeButtonTap: onHomeButtonTap,
                onResetGameTap: onResetGameTap,
                isFromMainMenu: isFromMainMenu,
                size: geometry.size
            )
        }
    }
}

// MARK: - Scene View (Stable Scene Management)
private struct SettingsSceneView: UIViewRepresentable {
    @Binding var isPresented: Bool
    var onHomeButtonTap: (() -> Void)?
    var onResetGameTap: (() -> Void)?
    var isFromMainMenu: Bool
    var size: CGSize
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.allowsTransparency = true
        skView.backgroundColor = .clear
        skView.isMultipleTouchEnabled = false
        
        // Create scene once
        let scene = SettingsScene(size: size)
        scene.scaleMode = .aspectFill
        scene.isFromMainMenu = isFromMainMenu
        scene.onDismiss = {
            DispatchQueue.main.async {
                isPresented = false
            }
        }
        scene.onHomeButtonTap = {
            DispatchQueue.main.async {
                isPresented = false
                onHomeButtonTap?()
            }
        }
        scene.onResetGameTap = {
            DispatchQueue.main.async {
                isPresented = false
                onResetGameTap?()
            }
        }
        
        skView.presentScene(scene)
        context.coordinator.scene = scene
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Update closures when bindings change, but don't recreate scene
        if let scene = context.coordinator.scene {
            scene.onDismiss = {
                DispatchQueue.main.async {
                    isPresented = false
                }
            }
            scene.onHomeButtonTap = {
                DispatchQueue.main.async {
                    isPresented = false
                    onHomeButtonTap?()
                }
            }
            scene.onResetGameTap = {
                DispatchQueue.main.async {
                    isPresented = false
                    onResetGameTap?()
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var scene: SettingsScene?
        
        deinit {
            // Clean up scene when coordinator is deallocated
            scene?.removeAllChildren()
            scene?.removeAllActions()
            scene = nil
        }
    }
    
    static func dismantleUIView(_ uiView: SKView, coordinator: Coordinator) {
        // Proper cleanup when view is removed
        coordinator.scene?.removeAllChildren()
        coordinator.scene?.removeAllActions()
        coordinator.scene = nil
        uiView.presentScene(nil)
    }
}




#Preview {
    @Previewable @State var isPresented = true
    return SettingsOverlayView(isPresented: $isPresented)
}
