//
//  SettingsOverlay.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 04/11/25.
//

import SpriteKit

class SettingsOverlay: SKNode, ResetConfirmationDialogDelegate {
    
    
    private let whiteColor = SKColor.white
    private let darkGrayColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private let lightPinkColor = SKColor(red: 0.98, green: 0.85, blue: 0.82, alpha: 1.0) // Softer peach/pink
    private let redToggleColor = SKColor(red: 0.75, green: 0.35, blue: 0.35, alpha: 1.0) // Softer red/brown
    private let separatorColor = SKColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) // Lighter separator
    
    private var backgroundNode: SKSpriteNode!
    private var closeButton: SKNode!
    
    // Settings components
    private var soundsToggle: ModernToggle!
    private var musicToggle: ModernToggle!
    private var vibrationToggle: ModernToggle!
    private var textSizeButtons: [String: TextSizeButton] = [:] // Store buttons by size name
    
    // Action buttons
    private var homeButton: SKNode!
    private var resetGameButton: SKNode!
    
    // Confirmation dialog
    private var resetConfirmationDialog: ResetConfirmationDialog!
    
    var onClose: (() -> Void)?
    var onHomeButtonTap: (() -> Void)?
    var onResetGameTap: (() -> Void)?
    
    // Whether this overlay is shown from main menu (affects which buttons are shown)
    var isFromMainMenu: Bool = false
    
    override init() {
        super.init()
        setupOverlay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupOverlay()
    }
    
    // Responsive calculation
    private var sceneSize: CGSize = CGSize(width: 932, height: 430) //
    
    func setSceneSize(_ size: CGSize) {
        sceneSize = size
    }
    
    private func setupOverlay() {

        let overlayWidth = sceneSize.width * 0.70
        let overlayHeight = sceneSize.height * 0.75
        let cornerRadius: CGFloat = 25

        // Cream/beige background overlay (similar to screenshot)
        let creamColor = SKColor(red: 0.96, green: 0.93, blue: 0.88, alpha: 0.85)
        let screenBg = SKSpriteNode(color: creamColor,
                                     size: CGSize(width: sceneSize.width * 2, height: sceneSize.height * 2))
        screenBg.position = CGPoint(x: 0, y: 0)
        screenBg.zPosition = 1000
        screenBg.name = "screenBackground"
        addChild(screenBg)

        // White modal with rounded corners
        let backgroundShape = SKShapeNode(rectOf: CGSize(width: overlayWidth, height: overlayHeight), cornerRadius: cornerRadius)
        backgroundShape.fillColor = whiteColor
        backgroundShape.strokeColor = .clear
        backgroundShape.position = CGPoint(x: 0, y: 0)
        backgroundShape.zPosition = 1001
        addChild(backgroundShape)

        // Note: Using SKShapeNode for rounded corners instead of SKSpriteNode
        backgroundNode = SKSpriteNode(color: .clear, size: CGSize(width: overlayWidth, height: overlayHeight))
        backgroundNode.position = CGPoint(x: 0, y: 0)
        backgroundNode.zPosition = 1001
        backgroundNode.name = "settingsBackground"
        // Not adding backgroundNode since we're using backgroundShape for the visual
        
        // Title "Settings"
        setupTitle()
        
        // Close button (X)
        setupCloseButton()
        
        // Settings toggles
        setupToggles()
        
        // Action buttons
        setupActionButtons()
        
        // Confirmation dialog (initially hidden)
        setupResetConfirmationDialog()
    }
    
    private func setupTitle() {
        let overlayWidth = sceneSize.width * 0.70
        let overlayHeight = sceneSize.height * 0.75
        let titleFontSize = max(28, min(overlayWidth * 0.038, 40))
        let titleLabel = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
        titleLabel.text = "Settings"
        titleLabel.fontSize = titleFontSize
        titleLabel.fontColor = darkGrayColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position = CGPoint(x: -overlayWidth * 0.35, y: overlayHeight * 0.35)
        titleLabel.zPosition = 1002
        addChild(titleLabel)
    }
    
    private func setupCloseButton() {
        let overlayWidth = sceneSize.width * 0.70
        let overlayHeight = sceneSize.height * 0.75
        let buttonSize: CGFloat = 35
        // Close button at top-right
        let buttonX = overlayWidth * 0.42
        let buttonY = overlayHeight * 0.33

        closeButton = SKNode()
        closeButton.name = "closeButton"
        closeButton.zPosition = 1002

        // Simple X mark in red/brown color (matching the screenshot)
        let closeBg = SKShapeNode(circleOfRadius: buttonSize / 2)
        closeBg.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        closeBg.strokeColor = .clear
        closeBg.zPosition = 0
        closeButton.addChild(closeBg)

        let xMark = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
        xMark.text = "✕"
        xMark.fontSize = buttonSize * 0.6
        xMark.fontColor = .white
        xMark.verticalAlignmentMode = .center
        xMark.horizontalAlignmentMode = .center
        xMark.zPosition = 1
        closeButton.addChild(xMark)

        closeButton.position = CGPoint(x: buttonX, y: buttonY)
        addChild(closeButton)
    }
    
    private func setupToggles() {
        let overlayWidth = sceneSize.width * 0.70
        let overlayHeight = sceneSize.height * 0.75
        let labelFontSize = max(20, min(overlayWidth * 0.028, 28))

        // Minimized spacing - tighter rows
        let startY = overlayHeight * 0.20
        let rowSpacing = overlayHeight * 0.12
        let labelX = -overlayWidth * 0.30
        let toggleX = overlayWidth * 0.30

        // Separator lines
        let separatorWidth = overlayWidth * 0.85

        // Sounds Toggle
        let soundsLabel = SKLabelNode(fontNamed: GaeguTypography.regularFontName)
        soundsLabel.text = "SFX"
        soundsLabel.fontSize = labelFontSize
        soundsLabel.fontColor = darkGrayColor
        soundsLabel.horizontalAlignmentMode = .left
        soundsLabel.position = CGPoint(x: labelX, y: startY)
        soundsLabel.zPosition = 1002
        addChild(soundsLabel)

        soundsToggle = ModernToggle(initialValue: SettingsManager.shared.sfxVolume > 0.0, toggleColor: redToggleColor)
        soundsToggle.position = CGPoint(x: toggleX, y: startY)
        soundsToggle.zPosition = 1002
        soundsToggle.name = "soundsToggle"
        addChild(soundsToggle)

        // Separator line after Sounds
        let separator1 = SKShapeNode(rectOf: CGSize(width: separatorWidth, height: 1))
        separator1.fillColor = separatorColor
        separator1.position = CGPoint(x: 0, y: startY - rowSpacing * 0.5)
        separator1.zPosition = 1002
        addChild(separator1)

        // Music Toggle
        let musicLabel = SKLabelNode(fontNamed: GaeguTypography.regularFontName)
        musicLabel.text = "Music"
        musicLabel.fontSize = labelFontSize
        musicLabel.fontColor = darkGrayColor
        musicLabel.horizontalAlignmentMode = .left
        musicLabel.position = CGPoint(x: labelX, y: startY - rowSpacing)
        musicLabel.zPosition = 1002
        addChild(musicLabel)

        musicToggle = ModernToggle(initialValue: SettingsManager.shared.musicVolume > 0.0, toggleColor: redToggleColor)
        musicToggle.position = CGPoint(x: toggleX, y: startY - rowSpacing)
        musicToggle.zPosition = 1002
        musicToggle.name = "musicToggle"
        addChild(musicToggle)

        // Separator line after Music
        let separator2 = SKShapeNode(rectOf: CGSize(width: separatorWidth, height: 1))
        separator2.fillColor = separatorColor
        separator2.position = CGPoint(x: 0, y: startY - rowSpacing * 1.5)
        separator2.zPosition = 1002
        addChild(separator2)

        // Vibration Toggle
        let vibrationLabel = SKLabelNode(fontNamed: GaeguTypography.regularFontName)
        vibrationLabel.text = "Vibration"
        vibrationLabel.fontSize = labelFontSize
        vibrationLabel.fontColor = darkGrayColor
        vibrationLabel.horizontalAlignmentMode = .left
        vibrationLabel.position = CGPoint(x: labelX, y: startY - rowSpacing * 2)
        vibrationLabel.zPosition = 1002
        addChild(vibrationLabel)

        vibrationToggle = ModernToggle(initialValue: SettingsManager.shared.isVibrationEnabled, toggleColor: redToggleColor)
        vibrationToggle.position = CGPoint(x: toggleX, y: startY - rowSpacing * 2)
        vibrationToggle.zPosition = 1002
        vibrationToggle.name = "vibrationToggle"
        addChild(vibrationToggle)

        // Separator line after Vibration
        let separator3 = SKShapeNode(rectOf: CGSize(width: separatorWidth, height: 1))
        separator3.fillColor = separatorColor
        separator3.position = CGPoint(x: 0, y: startY - rowSpacing * 2.5)
        separator3.zPosition = 1002
        addChild(separator3)

        // Text Size Label (moved to left side for group label)
        let textSizeLabel = SKLabelNode(fontNamed: GaeguTypography.regularFontName)
        textSizeLabel.text = "Text Size"
        textSizeLabel.fontSize = labelFontSize
        textSizeLabel.fontColor = darkGrayColor
        textSizeLabel.horizontalAlignmentMode = .left
        textSizeLabel.position = CGPoint(x: labelX, y: startY - rowSpacing * 3)
        textSizeLabel.zPosition = 1002
        addChild(textSizeLabel)

        // Text Size Selection Buttons
        setupTextSizeButtons(startY: startY - rowSpacing * 3, labelX: toggleX, labelFontSize: labelFontSize)

        // Final separator line
        let separator4Y = startY - rowSpacing * 3.5
        let separator4 = SKShapeNode(rectOf: CGSize(width: separatorWidth, height: 1))
        separator4.fillColor = separatorColor
        separator4.position = CGPoint(x: 0, y: separator4Y)
        separator4.zPosition = 1002
        addChild(separator4)
    }

    private func setupTextSizeButtons(startY: CGFloat, labelX: CGFloat, labelFontSize: CGFloat) {
        let buttonWidth: CGFloat = 55
        let buttonHeight: CGFloat = 28
        let buttonSpacing: CGFloat = 12
        let currentSize = TextSizeManager.shared.currentTextSize
        let fontSize = labelFontSize * 0.7

        // Button configuration data - cleaner and more maintainable
        let buttonConfigs: [(text: String, size: TextSize, key: String, xOffset: CGFloat)] = [
            ("Normal", .normal, "normal", -buttonWidth - buttonSpacing),
            ("Large", .large, "large", 0),
            ("X-Large", .extraLarge, "extraLarge", buttonWidth + buttonSpacing)
        ]

        // Create buttons using configuration - reduces code duplication
        for config in buttonConfigs {
            let button = TextSizeButton(
                text: config.text,
                size: config.size,
                isSelected: currentSize == config.size,
                width: buttonWidth,
                height: buttonHeight,
                fontSize: fontSize,
                selectedColor: redToggleColor,
                unselectedColor: lightPinkColor
            )
            button.position = CGPoint(x: labelX + config.xOffset, y: startY)
            button.zPosition = 1002
            button.name = "textSize\(config.key)"
            addChild(button)
            textSizeButtons[config.key] = button
        }
    }

    private func setupActionButtons() {
        let overlayWidth = sceneSize.width * 0.70
        let overlayHeight = sceneSize.height * 0.75
        let buttonHeight = max(40, min(overlayHeight * 0.08, 48))
        let buttonFontSize = max(16, min(overlayWidth * 0.024, 20))
        let buttonCornerRadius: CGFloat = 8

        let spacingAfterSeparator = overlayHeight * 0.08
        // Updated to account for 4 separators now (text size was added)
        let separator4Y = overlayHeight * 0.20 - overlayHeight * 0.12 * 3.5
        let topButtonY = separator4Y - spacingAfterSeparator
        // Use 100% of available width (with some padding)
        let totalAvailableWidth = overlayWidth * 0.80
        let buttonWidth = totalAvailableWidth

        if isFromMainMenu {
            // Only show Reset Game button (full width)
            resetGameButton = createActionButton(text: "Reset Game", width: buttonWidth, height: buttonHeight,
                                                 cornerRadius: buttonCornerRadius, fontSize: buttonFontSize)
            resetGameButton.position = CGPoint(x: 0, y: topButtonY)
            resetGameButton.name = "resetGameButton"
            resetGameButton.zPosition = 1002
            addChild(resetGameButton)
        } else {
            // Only show Back to home button (full width)
            homeButton = createActionButton(text: "Back to home", width: buttonWidth, height: buttonHeight,
                                           cornerRadius: buttonCornerRadius, fontSize: buttonFontSize)
            homeButton.position = CGPoint(x: 0, y: topButtonY)
            homeButton.name = "homeButton"
            homeButton.zPosition = 1002
            addChild(homeButton)
        }
    }
    
    private func createActionButton(text: String, width: CGFloat, height: CGFloat, cornerRadius: CGFloat, fontSize: CGFloat) -> SKNode {
        let button = SKNode()
        
        let buttonBg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: cornerRadius)
        buttonBg.fillColor = lightPinkColor
        buttonBg.strokeColor = .clear
        buttonBg.zPosition = 0
        button.addChild(buttonBg)
        
        let buttonLabel = SKLabelNode(fontNamed: GaeguTypography.regularFontName)
        buttonLabel.text = text
        buttonLabel.fontSize = fontSize
        buttonLabel.fontColor = darkGrayColor
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.zPosition = 1
        button.addChild(buttonLabel)
        
        return button
    }
    
    // MARK: - Reset Confirmation Dialog
    
    private func setupResetConfirmationDialog() {
        resetConfirmationDialog = ResetConfirmationDialog()
        resetConfirmationDialog.setSceneSize(sceneSize)
        resetConfirmationDialog.delegate = self
        addChild(resetConfirmationDialog)
    }
    
    // MARK: - ResetConfirmationDialogDelegate
    
    func resetConfirmationDialogDidConfirm() {
        // This will be handled by the controller through the onResetGameTap closure
        // We need to pass this to the controller, but we don't have direct access here
        // Instead, we'll use a closure pattern
        onResetGameTap?()
    }
    
    func resetConfirmationDialogDidCancel() {
        // Dialog is already hidden, nothing else to do
    }
    
    // MARK: - Touch Handling
    
    func handleTouch(at location: CGPoint, controller: SettingsOverlayController) -> Bool {
        let touchedNode = atPoint(location)

        // If confirmation dialog is visible, let it handle the touch
        if resetConfirmationDialog.isVisible {
            return resetConfirmationDialog.handleTouch(at: location)
        }

        // Check if touch is on text size buttons - optimized with early exit
        var node: SKNode? = touchedNode
        while node != nil && node != self {
            // Check if this node or its parent is a text size button
            if let button = node as? TextSizeButton ?? node?.parent as? TextSizeButton {
                if !button.isSelected { // Only update if selecting a different button
                    // Deselect all buttons and select the tapped one
                    textSizeButtons.values.forEach { $0.isSelected = false }
                    button.isSelected = true
                    TextSizeManager.shared.currentTextSize = button.textSize
                    controller.handleTextSizeChange(button.textSize)
                }
                return true
            }
            node = node?.parent
        }

        // Check toggles
        node = touchedNode
        while node != nil && node != self {
            if let toggle = node as? ModernToggle {
                toggle.toggle()

                // Delegate to controller
                if toggle == soundsToggle {
                    controller.handleSoundsToggle(toggle.isOn)
                } else if toggle == musicToggle {
                    controller.handleMusicToggle(toggle.isOn)
                } else if toggle == vibrationToggle {
                    controller.handleVibrationToggle(toggle.isOn)
                }
                return true
            }
            node = node?.parent
        }
        
        // Check action buttons
        if let nodeName = touchedNode.name {
            switch nodeName {
            case "closeButton":
                controller.handleCloseTap()
                return true
            case "homeButton":
                controller.handleHomeButtonTap()
                return true
            case "resetGameButton":
                // Show confirmation dialog instead of immediately resetting
                resetConfirmationDialog.show()
                return true
            default:
                break
            }
        }
        
        // Check parent nodes for buttons
        node = touchedNode.parent
        while node != nil && node != self {
            if let nodeName = node?.name {
                switch nodeName {
                case "closeButton":
                    controller.handleCloseTap()
                    return true
                case "homeButton":
                    controller.handleHomeButtonTap()
                    return true
                case "resetGameButton":
                    // Show confirmation dialog instead of immediately resetting
                    resetConfirmationDialog.show()
                    return true
                default:
                    break
                }
            }
            node = node?.parent
        }
        
        return false
    }
    
    // MARK: - Public Touch
    
    func handleTouchBegan(_ touch: UITouch, controller: SettingsOverlayController) -> Bool {
        let location = touch.location(in: self)
        return handleTouch(at: location, controller: controller)
    }
    
    func handleTouchMoved(_ touch: UITouch, controller: SettingsOverlayController) -> Bool {
        
        return false
    }
    
    func handleTouchEnded(_ touch: UITouch, controller: SettingsOverlayController) -> Bool {
        return false
    }
    
    func show(in scene: SKScene) {
        // Remove from current parent if already added
        if parent != nil {
            removeFromParent()
        }

        alpha = 0.0
        scene.addChild(self)
        run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    func close() {
        run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ])) {
            self.onClose?()
        }
    }
    
    func closeImmediately() {
        removeFromParent()
        onClose?()
    }
    
    func presentInScene(_ scene: SKScene, isFromMainMenu: Bool = false) {
        // Size for responsive calculations
        setSceneSize(scene.size)
        self.isFromMainMenu = isFromMainMenu
        // Recreate overlay sizenya repsonsive
        removeAllChildren()
        setupOverlay()
        // Recreate confirmation dialog (it was removed with removeAllChildren)
        setupResetConfirmationDialog()
        // Overlay center
        position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        show(in: scene)
    }
}

// MARK: - Volume Slider Component

class VolumeSlider: SKNode {
    private let trackWidth: CGFloat
    private var trackNode: SKShapeNode!
    private var knobNode: SKShapeNode!
    private var leftArrow: SKLabelNode!
    private var rightArrow: SKLabelNode!
    
    let woodColor = SKColor(red: 0.40, green: 0.25, blue: 0.16, alpha: 1.0)
    let darkWoodColor = SKColor(red: 0.25, green: 0.15, blue: 0.10, alpha: 1.0)
    
    var currentValue: Float = 1.0
    private let minX: CGFloat
    private let maxX: CGFloat
    
    init(width: CGFloat, initialValue: Float) {
        self.trackWidth = width
        self.currentValue = initialValue
        self.minX = -width / 2
        self.maxX = width / 2
        
        super.init()
        
        setupSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSlider() {
        // Track
        trackNode = SKShapeNode(rectOf: CGSize(width: trackWidth, height: 12))
        trackNode.fillColor = woodColor
        trackNode.strokeColor = darkWoodColor
        trackNode.lineWidth = 2
        trackNode.position = CGPoint(x: 0, y: 0)
        trackNode.zPosition = 0
        trackNode.name = "sliderTrack"
        trackNode.isUserInteractionEnabled = false
        addChild(trackNode)
        
        // Knob
        let knobRadius: CGFloat = 25
        knobNode = SKShapeNode(circleOfRadius: knobRadius)
        knobNode.fillColor = woodColor
        knobNode.strokeColor = darkWoodColor
        knobNode.lineWidth = 3
        knobNode.zPosition = 1
        knobNode.name = "sliderKnob"
        knobNode.isUserInteractionEnabled = false
        addChild(knobNode)
        
        // Left arrow
        leftArrow = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
        leftArrow.text = "◄"
        leftArrow.fontSize = 18
        leftArrow.fontColor = .white
        leftArrow.position = CGPoint(x: -knobRadius * 0.4, y: 0)
        leftArrow.zPosition = 2
        knobNode.addChild(leftArrow)
        
        // Right arrow
        rightArrow = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
        rightArrow.text = "►"
        rightArrow.fontSize = 18
        rightArrow.fontColor = .white
        rightArrow.position = CGPoint(x: knobRadius * 0.4, y: 0)
        rightArrow.zPosition = 2
        knobNode.addChild(rightArrow)
        
        updateKnobPosition()
    }
    
    func setupNames(_ baseName: String) {
        self.name = baseName
        trackNode.name = "\(baseName)Track"
        knobNode.name = "\(baseName)Knob"
    }
    
    private func updateKnobPosition() {
        let normalizedValue = CGFloat(currentValue)
        knobNode.position.x = minX + (maxX - minX) * normalizedValue
    }
    
    func handleDragStart(_ location: CGPoint) {
        updateValue(from: location.x)
    }
    
    func handleDrag(_ location: CGPoint) {
        updateValue(from: location.x)
    }
    
    private func updateValue(from xPosition: CGFloat) {
        let clampedX = max(minX, min(maxX, xPosition))
        let normalizedValue = (clampedX - minX) / (maxX - minX)
        currentValue = Float(normalizedValue)
        updateKnobPosition()
    }
}

// MARK: - Toggle Switch

class WoodenToggle: SKNode {
    private var leftSegment: SKShapeNode!
    private var rightSegment: SKShapeNode!
    private var leftLabel: SKLabelNode!
    private var rightLabel: SKLabelNode!
    
    let woodColor = SKColor(red: 0.40, green: 0.25, blue: 0.16, alpha: 1.0)
    let darkWoodColor = SKColor(red: 0.25, green: 0.15, blue: 0.10, alpha: 1.0)
    let highlightedColor = SKColor(red: 0.55, green: 0.35, blue: 0.22, alpha: 1.0)
    
    var isOn: Bool = false
    
    init(initialValue: Bool) {
        self.isOn = initialValue
        super.init()
        setupToggle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupToggle() {
        let segmentWidth: CGFloat = 80
        let segmentHeight: CGFloat = 50
        let segmentSpacing: CGFloat = 5
        
        
        leftSegment = SKShapeNode(rectOf: CGSize(width: segmentWidth, height: segmentHeight))
        leftSegment.fillColor = isOn ? highlightedColor : woodColor
        leftSegment.strokeColor = darkWoodColor
        leftSegment.lineWidth = 2
        leftSegment.position = CGPoint(x: -(segmentWidth / 2 + segmentSpacing / 2), y: 0)
        leftSegment.zPosition = 0
        addChild(leftSegment)
        
        leftLabel = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
        leftLabel.text = "000"
        leftLabel.fontSize = 24
        leftLabel.fontColor = .white
        leftLabel.position = CGPoint(x: 0, y: 0)
        leftLabel.zPosition = 1
        leftSegment.addChild(leftLabel)
        
        
        rightSegment = SKShapeNode(rectOf: CGSize(width: segmentWidth, height: segmentHeight))
        rightSegment.fillColor = isOn ? woodColor : highlightedColor
        rightSegment.strokeColor = darkWoodColor
        rightSegment.lineWidth = 2
        rightSegment.position = CGPoint(x: segmentWidth / 2 + segmentSpacing / 2, y: 0)
        rightSegment.zPosition = 0
        addChild(rightSegment)
        
        rightLabel = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
        rightLabel.text = isOn ? "ON" : "OFF"
        rightLabel.fontSize = 20
        rightLabel.fontColor = .white
        rightLabel.position = CGPoint(x: 0, y: 0)
        rightLabel.zPosition = 1
        rightSegment.addChild(rightLabel)
    }
    
    func toggle() {
        isOn.toggle()
        updateAppearance()
    }
    
    private func updateAppearance() {
        leftSegment.fillColor = isOn ? highlightedColor : woodColor
        rightSegment.fillColor = isOn ? woodColor : highlightedColor
        rightLabel.text = isOn ? "ON" : "OFF"
    }
}

// MARK: - Checkbox

class WoodenCheckbox: SKNode {
    private var checkboxCircle: SKShapeNode!
    private var checkmark: SKLabelNode?
    
    let woodColor = SKColor(red: 0.40, green: 0.25, blue: 0.16, alpha: 1.0)
    let darkWoodColor = SKColor(red: 0.25, green: 0.15, blue: 0.10, alpha: 1.0)
    
    var isOn: Bool = false
    
    init(initialValue: Bool) {
        self.isOn = initialValue
        super.init()
        setupCheckbox()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCheckbox() {
        let radius: CGFloat = 30
        
        checkboxCircle = SKShapeNode(circleOfRadius: radius)
        checkboxCircle.fillColor = isOn ? darkWoodColor : woodColor
        checkboxCircle.strokeColor = darkWoodColor
        checkboxCircle.lineWidth = 3
        checkboxCircle.zPosition = 0
        addChild(checkboxCircle)
        
        if isOn {
            checkmark = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
            checkmark!.text = "✓"
            checkmark!.fontSize = 40
            checkmark!.fontColor = .white
            checkmark!.verticalAlignmentMode = .center
            checkmark!.zPosition = 1
            addChild(checkmark!)
        }
    }
    
    func toggle() {
        isOn.toggle()
        updateAppearance()
    }
    
    private func updateAppearance() {
        checkboxCircle.fillColor = isOn ? darkWoodColor : woodColor
        
        if isOn {
            if checkmark == nil {
                checkmark = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
                checkmark!.text = "✓"
                checkmark!.fontSize = 40
                checkmark!.fontColor = .white
                checkmark!.verticalAlignmentMode = .center
                checkmark!.zPosition = 1
                addChild(checkmark!)
            }
        } else {
            checkmark?.removeFromParent()
            checkmark = nil
        }
    }
}

// MARK: - Toggle Switch

class ModernToggle: SKNode {
    private var trackNode: SKShapeNode!
    private var knobNode: SKShapeNode!
    
    private let toggleColor: SKColor
    private let trackOffColor = SKColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    private let knobColor = SKColor.white
    
    var isOn: Bool = false
    
    init(initialValue: Bool, toggleColor: SKColor) {
        self.isOn = initialValue
        self.toggleColor = toggleColor
        super.init()
        setupToggle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupToggle() {
        // Toggle track (horizontal rectangle)
        let trackWidth: CGFloat = 50
        let trackHeight: CGFloat = 30
        
        trackNode = SKShapeNode(rectOf: CGSize(width: trackWidth, height: trackHeight), cornerRadius: trackHeight / 2)
        trackNode.fillColor = isOn ? toggleColor : trackOffColor
        trackNode.strokeColor = .clear
        trackNode.zPosition = 0
        trackNode.isUserInteractionEnabled = false
        addChild(trackNode)
        
        // Toggle knob (circular)
        let knobRadius: CGFloat = 12
        let knobX = isOn ? trackWidth / 2 - knobRadius - 2 : -trackWidth / 2 + knobRadius + 2
        
        knobNode = SKShapeNode(circleOfRadius: knobRadius)
        knobNode.fillColor = knobColor
        knobNode.strokeColor = .clear
        knobNode.position = CGPoint(x: knobX, y: 0)
        knobNode.zPosition = 1
        knobNode.isUserInteractionEnabled = false
        addChild(knobNode)
    }
    
    func toggle() {
        isOn.toggle()
        updateAppearance()
    }
    
    private func updateAppearance() {
        let trackWidth: CGFloat = 50
        let knobRadius: CGFloat = 12
        let knobX = isOn ? trackWidth / 2 - knobRadius - 2 : -trackWidth / 2 + knobRadius + 2
        
        
        trackNode.fillColor = isOn ? toggleColor : trackOffColor
        
        
        let moveAction = SKAction.moveTo(x: knobX, duration: 0.2)
        moveAction.timingMode = .easeInEaseOut
        knobNode.run(moveAction)
    }
}

// MARK: - Text Size Button

class TextSizeButton: SKNode {
    private var backgroundNode: SKShapeNode!
    private var labelNode: SKLabelNode!

    let textSize: TextSize
    var isSelected: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    private let selectedColor: SKColor
    private let unselectedColor: SKColor
    private let textColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private let borderColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)

    init(text: String, size: TextSize, isSelected: Bool, width: CGFloat, height: CGFloat, fontSize: CGFloat, selectedColor: SKColor, unselectedColor: SKColor) {
        self.textSize = size
        self.isSelected = isSelected
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        super.init()

        setupButton(text: text, width: width, height: height, fontSize: fontSize)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton(text: String, width: CGFloat, height: CGFloat, fontSize: CGFloat) {
        // Background
        backgroundNode = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 4)
        backgroundNode.strokeColor = borderColor
        backgroundNode.lineWidth = 1
        backgroundNode.zPosition = 0
        addChild(backgroundNode)

        // Label
        labelNode = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
        labelNode.text = text
        labelNode.fontSize = fontSize
        labelNode.fontColor = textColor
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.zPosition = 1
        addChild(labelNode)

        updateAppearance()
    }

    private func updateAppearance() {
        backgroundNode.fillColor = isSelected ? selectedColor : unselectedColor
    }

    func select() {
        isSelected = true
    }
}
