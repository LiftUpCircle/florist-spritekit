//
//  ResetConfirmationDialog.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 11/11/25.
//

import SpriteKit

protocol ResetConfirmationDialogDelegate: AnyObject {
    func resetConfirmationDialogDidConfirm()
    func resetConfirmationDialogDidCancel()
}

class ResetConfirmationDialog: SKNode {
    
    // MARK: - Properties
    
    private let whiteColor = SKColor.white
    private let darkGrayColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private let lightPinkColor = SKColor(red: 0.98, green: 0.85, blue: 0.82, alpha: 1.0)
    
    private var dialogNode: SKNode!
    private var yesButton: SKNode!
    private var noButton: SKNode!
    
    weak var delegate: ResetConfirmationDialogDelegate?
    
    private var sceneSize: CGSize = CGSize(width: 932, height: 430)
    var isVisible: Bool = false
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupDialog()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDialog()
    }
    
    // MARK: - Setup
    
    func setSceneSize(_ size: CGSize) {
        sceneSize = size
        // Recreate dialog with new size
        removeAllChildren()
        setupDialog()
    }
    
    private func setupDialog() {
        let overlayWidth = sceneSize.width * 0.70
        let overlayHeight = sceneSize.height * 0.75
        
        // Create dialog container
        dialogNode = SKNode()
        dialogNode.name = "confirmationDialog"
        dialogNode.zPosition = 2000 // Above everything
        dialogNode.isHidden = true
        addChild(dialogNode)
        
        // Semi-transparent background overlay
        let dialogBg = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.5),
                                     size: CGSize(width: sceneSize.width * 2, height: sceneSize.height * 2))
        dialogBg.position = CGPoint(x: 0, y: 0)
        dialogBg.zPosition = 0
        dialogBg.name = "confirmationBackground"
        dialogNode.addChild(dialogBg)
        
        // Dialog box - smaller width, higher height
        let dialogWidth = overlayWidth * 0.65  // Reduced from 0.85
        let dialogHeight = overlayHeight * 0.55  // Increased from 0.40
        let dialogBox = SKShapeNode(rectOf: CGSize(width: dialogWidth, height: dialogHeight), cornerRadius: 20)
        dialogBox.fillColor = whiteColor
        dialogBox.strokeColor = .clear
        dialogBox.position = CGPoint(x: 0, y: 0)
        dialogBox.zPosition = 1
        dialogBox.name = "confirmationBox"
        dialogNode.addChild(dialogBox)
        
        // Title
//        let titleLabel = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
//        titleLabel.text = "Reset Game?"
//        titleLabel.fontSize = max(24, min(overlayWidth * 0.032, 32))
//        titleLabel.fontColor = darkGrayColor
//        titleLabel.verticalAlignmentMode = .center
//        titleLabel.horizontalAlignmentMode = .center
//        titleLabel.position = CGPoint(x: 0, y: dialogHeight * 0.25)
//        titleLabel.zPosition = 2
//        dialogNode.addChild(titleLabel)
        
        // Message (split into two lines since SKLabelNode doesn't support numberOfLines)
        // Position text near the top with minimal padding
        let textTopPadding: CGFloat = 20  // Small padding from top
        let lineSpacing: CGFloat = 25  // Spacing between lines
        
        let messageLine1 = SKLabelNode(fontNamed: GaeguTypography.regularFontName)
        messageLine1.text = "Are you sure you want to"
        messageLine1.fontSize = max(16, min(overlayWidth * 0.022, 20))
        messageLine1.fontColor = darkGrayColor
        messageLine1.verticalAlignmentMode = .center
        messageLine1.horizontalAlignmentMode = .center
        messageLine1.position = CGPoint(x: 0, y: dialogHeight / 2 - textTopPadding)
        messageLine1.zPosition = 2
        dialogNode.addChild(messageLine1)
        
        let messageLine2 = SKLabelNode(fontNamed: GaeguTypography.regularFontName)
        messageLine2.text = "reset the game?"
        messageLine2.fontSize = max(16, min(overlayWidth * 0.022, 20))
        messageLine2.fontColor = darkGrayColor
        messageLine2.verticalAlignmentMode = .center
        messageLine2.horizontalAlignmentMode = .center
        messageLine2.position = CGPoint(x: 0, y: dialogHeight / 2 - textTopPadding - lineSpacing)
        messageLine2.zPosition = 2
        dialogNode.addChild(messageLine2)
        
        // Divider line after message text
        let separatorColor = SKColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        let dividerWidth = dialogWidth * 0.85
        let divider = SKShapeNode(rectOf: CGSize(width: dividerWidth, height: 1))
        divider.fillColor = separatorColor
        divider.strokeColor = .clear
        divider.position = CGPoint(x: 0, y: dialogHeight * 0.05)  // Position higher, closer to the text
        divider.zPosition = 2
        dialogNode.addChild(divider)
        
        // Buttons container
        let buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: 0, y: -dialogHeight * 0.25)
        buttonContainer.zPosition = 2
        dialogNode.addChild(buttonContainer)
        
        // Button dimensions
        let buttonWidth = dialogWidth * 0.35
        let buttonHeight = max(40, min(dialogHeight * 0.15, 50))
        let buttonFontSize = max(16, min(overlayWidth * 0.022, 20))
        let buttonSpacing: CGFloat = 20
        
        // Yes button (destructive - red/pink)
        yesButton = createButton(
            text: "Yes",
            width: buttonWidth,
            height: buttonHeight,
            fontSize: buttonFontSize,
            color: SKColor(red: 0.294, green: 0.867, blue: 0.333, alpha: 1.0))
        yesButton.position = CGPoint(x: -buttonWidth / 2 - buttonSpacing / 2, y: 0)
        yesButton.name = "confirmationYesButton"
        buttonContainer.addChild(yesButton)
        
        // No button (cancel - light pink)
        noButton = createButton(
            text: "No",
            width: buttonWidth,
            height: buttonHeight,
            fontSize: buttonFontSize,
            color: SKColor(red: 0.867, green: 0.294, blue: 0.306, alpha: 1.0)
        )
        noButton.position = CGPoint(x: buttonWidth / 2 + buttonSpacing / 2, y: 0)
        noButton.name = "confirmationNoButton"
        buttonContainer.addChild(noButton)
    }
    
    private func createButton(text: String, width: CGFloat, height: CGFloat, fontSize: CGFloat, color: SKColor) -> SKNode {
        let button = SKNode()
        
        let buttonBg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        buttonBg.fillColor = color
        buttonBg.strokeColor = .clear
        buttonBg.zPosition = 0
        button.addChild(buttonBg)
        
        let buttonLabel = SKLabelNode(fontNamed: GaeguTypography.boldFontName)
        buttonLabel.text = text
        buttonLabel.fontSize = fontSize
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.zPosition = 1
        button.addChild(buttonLabel)
        
        return button
    }
    
    // MARK: - Public Methods
    
    func show() {
        isVisible = true
        dialogNode.isHidden = false
        dialogNode.alpha = 0.0
        dialogNode.run(SKAction.fadeIn(withDuration: 0.2))
    }
    
    func hide() {
        isVisible = false
        dialogNode.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.run {
                self.dialogNode.isHidden = true
            }
        ]))
    }
    
    // MARK: - Touch Handling
    
    func handleTouch(at location: CGPoint) -> Bool {
        guard isVisible else { return false }
        
        let touchedNode = atPoint(location)
        
        // Check if touching confirmation buttons
        var node: SKNode? = touchedNode
        while node != nil && node != self {
            if let nodeName = node?.name {
                switch nodeName {
                case "confirmationYesButton":
                    hide()
                    delegate?.resetConfirmationDialogDidConfirm()
                    return true
                case "confirmationNoButton":
                    hide()
                    delegate?.resetConfirmationDialogDidCancel()
                    return true
                case "confirmationBackground":
                    // Tapping background closes the dialog (like cancel)
                    hide()
                    delegate?.resetConfirmationDialogDidCancel()
                    return true
                default:
                    break
                }
            }
            node = node?.parent
        }
        
        // Check if the touched node is a child of confirmation dialog
        var checkNode: SKNode? = touchedNode
        while checkNode != nil {
            if checkNode == dialogNode {
                // Touched inside dialog but not a button - consume touch
                return true
            }
            checkNode = checkNode?.parent
        }
        
        return false
    }
}

