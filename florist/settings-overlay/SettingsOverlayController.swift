//
//  SettingsOverlayController.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 04/11/25.
//

import SpriteKit

protocol SettingsOverlayControllerDelegate: AnyObject {
    func settingsOverlayDidClose()
    func settingsOverlayDidTapRateGame()
    func settingsOverlayDidTapSubscriptions()
    func settingsOverlayDidTapContactUs()
    func settingsOverlayDidTapPrivacy()
}

class SettingsOverlayController {
    
    // MARK: - Properties
    
    private var overlay: SettingsOverlay
    private let settingsManager = SettingsManager.shared
    weak var delegate: SettingsOverlayControllerDelegate?
    
    // MARK: - Initialization
    
    init(scene: SKScene) {
        overlay = SettingsOverlay()
        overlay.presentInScene(scene)
        setupOverlayDelegates()
    }
    
    // MARK: - Setup
    
    private func setupOverlayDelegates() {
        overlay.onClose = { [weak self] in
            self?.delegate?.settingsOverlayDidClose()
        }
    }
    
    // MARK: - Public Methods
    
    func show(in scene: SKScene) {
        overlay.presentInScene(scene)
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
    
    func handleRateGameTap() {
        settingsManager.triggerVibration(style: .light)
        delegate?.settingsOverlayDidTapRateGame()
    }
    
    func handleSubscriptionsTap() {
        settingsManager.triggerVibration(style: .light)
        delegate?.settingsOverlayDidTapSubscriptions()
    }
    
    func handleContactUsTap() {
        settingsManager.triggerVibration(style: .light)
        delegate?.settingsOverlayDidTapContactUs()
    }
    
    func handlePrivacyTap() {
        settingsManager.triggerVibration(style: .light)
        delegate?.settingsOverlayDidTapPrivacy()
    }
    
    func handleCloseTap() {
        overlay.close()
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

