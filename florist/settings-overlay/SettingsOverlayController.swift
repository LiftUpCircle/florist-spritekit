//
//  SettingsOverlayController.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 04/11/25.
//

import SpriteKit

// Notification name for home button tap
extension Notification.Name {
    static let settingsOverlayDidTapHomeButton = Notification.Name("settingsOverlayDidTapHomeButton")
}

protocol SettingsOverlayControllerDelegate: AnyObject {
    func settingsOverlayDidClose()
    func settingsOverlayDidTapHomeButton()
    
}

class SettingsOverlayController {
    
    // MARK: - Properties
    
    private var overlay: SettingsOverlay
    private let settingsManager = SettingsManager.shared
    weak var delegate: SettingsOverlayControllerDelegate?
    var onHomeButtonTap: (() -> Void)?
    var onResetGameTap: (() -> Void)?
    
    // MARK: - Initialization
    
    init(scene: SKScene, isFromMainMenu: Bool = false) {
        overlay = SettingsOverlay()
        overlay.isFromMainMenu = isFromMainMenu
        overlay.presentInScene(scene, isFromMainMenu: isFromMainMenu)
        setupOverlayDelegates()
    }
    
    // MARK: - Setup
    
    private func setupOverlayDelegates() {
        overlay.onClose = { [weak self] in
            self?.delegate?.settingsOverlayDidClose()
        }
        overlay.onHomeButtonTap = { [weak self] in
            self?.delegate?.settingsOverlayDidTapHomeButton()
        }
        overlay.onResetGameTap = { [weak self] in
            // When reset is confirmed, call handleResetGameConfirm
            self?.handleResetGameConfirm()
        }
    }
    
    // MARK: - Public Methods
    
    func show(in scene: SKScene, isFromMainMenu: Bool = false) {
        overlay.isFromMainMenu = isFromMainMenu
        overlay.presentInScene(scene, isFromMainMenu: isFromMainMenu)
    }
    
    func hide() {
        overlay.close()
    }
    
    // MARK: - Settings Updates
    
    func handleSoundsToggle(_ isOn: Bool) {
        settingsManager.sfxVolume = isOn ? 1.0 : 0.0
        settingsManager.triggerVibration(style: .light)
    }
    
    func handleMusicToggle(_ isOn: Bool) {
        settingsManager.musicVolume = isOn ? 1.0 : 0.0
        settingsManager.triggerVibration(style: .light)
    }
    
    func handleVibrationToggle(_ isOn: Bool) {
        settingsManager.isVibrationEnabled = isOn
        settingsManager.triggerVibration()
    }
    
    // MARK: - Action Button Handlers
    
    func handleHomeButtonTap() {
        settingsManager.triggerVibration(style: .light)
        // Remove overlay immediately without animation to allow navigation
        overlay.closeImmediately()
        // Post notification first so observers can handle it
        // Touch events in SpriteKit are already on main thread
        NotificationCenter.default.post(name: .settingsOverlayDidTapHomeButton, object: nil, userInfo: ["action": "navigateToMainMenu"])
        // Call closure if provided (highest priority for direct navigation)
        onHomeButtonTap?()
        // Notify delegate (will post notification again if using default implementation)
        delegate?.settingsOverlayDidTapHomeButton()
    }
    
    func handleCloseTap() {
        overlay.close()
    }
    
    func handleResetGameTap() {
        // This method is now called when reset button is tapped
        // The confirmation dialog will be shown by the overlay
        // This method is kept for backward compatibility but shouldn't be called directly
        settingsManager.triggerVibration(style: .light)
    }
    
    func handleResetGameConfirm() {
        // This is called when user confirms the reset in the confirmation dialog
        settingsManager.triggerVibration(style: .light)
        // Remove overlay immediately without animation
        overlay.closeImmediately()
        // Call the reset game closure
        onResetGameTap?()
    }
    
    // MARK: - Touch Handling
    
    func handleTouch(at location: CGPoint) -> Bool {
       
        guard let scene = overlay.scene else { return false }
        let overlayLocation = overlay.convert(location, from: scene)
        return overlay.handleTouch(at: overlayLocation, controller: self)
    }
    
    func handleTouchBegan(_ touch: UITouch) -> Bool {
        return overlay.handleTouchBegan(touch, controller: self)
    }
    
    func handleTouchMoved(_ touch: UITouch) -> Bool {
        return overlay.handleTouchMoved(touch, controller: self)
    }
    
    func handleTouchEnded(_ touch: UITouch) -> Bool {
        return overlay.handleTouchEnded(touch, controller: self)
    }
    
    // MARK: - Current Settings State
    
    var currentSoundsState: Bool {
        return settingsManager.sfxVolume > 0.0
    }
    
    var currentMusicState: Bool {
        return settingsManager.musicVolume > 0.0
    }
    
    var currentVibrationState: Bool {
        return settingsManager.isVibrationEnabled
    }
}

// MARK: - Default Implementation
extension SettingsOverlayControllerDelegate {
    func settingsOverlayDidTapHomeButton() {
        // Default implementation - posts notification for views to observe
        // This ensures the notification is posted even if the delegate doesn't implement this method
        NotificationCenter.default.post(name: .settingsOverlayDidTapHomeButton, object: nil)
    }
}
