//
//  GameScene.swift
//  florist
//
//  Created by reynaldo on 28/10/25.
//

import SpriteKit
import GameplayKit

// MARK: - Flower Node
class FlowerNode: SKSpriteNode {
    var isInInventory: Bool = true
    var originalPosition: CGPoint = .zero
    var flowerData: Flower
    var inventoryIndex: Int = 0
    
    init(flower: Flower, imageName: String, size: CGSize) {
        self.flowerData = flower
        
        // Try to load the flower image from assets
        if let texture = SKTexture(imageNamed: imageName) as SKTexture? {
            super.init(texture: texture, color: .clear, size: size)
        } else {
            // Fallback to colored sprite if image not found
            super.init(texture: nil, color: flower.flowerColor, size: size)
        }
        
        self.name = "flower_\(flower.flowerName)"
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Create a copy of this flower node
    func createCopy() -> FlowerNode {
        let imageName = getImageName(for: flowerData.flowerName)
        let copy = FlowerNode(flower: flowerData, imageName: imageName, size: self.size)
        copy.isInInventory = false
        
        // Copy visual children
        for child in self.children {
            if let childCopy = child.copy() as? SKNode {
                copy.addChild(childCopy)
            }
        }
        
        return copy
    }
    
    private func getImageName(for flowerName: String) -> String {
        // Map flower names to asset names
        switch flowerName {
        case "Rose": return "Rose"
        case "Jasmine": return "Jasmine"
        case "Lavender": return "Lavender"
        case "Hibiscus": return "Hibicus" // Note: asset is named "Hibicus"
        default: return ""
        }
    }
}

// MARK: - Game Scene
class GameScene: SKScene, SKPhysicsContactDelegate {

    // Background
    private var backgroundSprite: SKSpriteNode!

    // UI Areas
    private var inventoryScrollNode: SKNode!
    private var inventoryCropNode: SKCropNode!
    private var chatBoxNode: SKSpriteNode!
    private var chatTextNode: SKLabelNode!

    // Bouquet images
    private var bouquetBackNode: SKSpriteNode!
    private var bouquetFrontNode: SKSpriteNode!
    private var bouquetFlowersContainer: SKNode!
    private var bouquetPlacementArea: SKSpriteNode! // Invisible physics body for placement area

    // Inventory flowers (original templates)
    private var inventoryFlowers: [FlowerNode] = []
    private var inventoryScrollOffset: CGFloat = 0
    private var maxScrollOffset: CGFloat = 0

    // Placed flowers (freeform placement)
    private var placedFlowers: [FlowerNode] = []
    private let maxFlowers = 15 // Increased limit for freeform placement

    // Drag state
    private var selectedFlower: FlowerNode?
    private var isDraggingFromInventory: Bool = false
    private var draggedFlowerCopy: FlowerNode?
    private var isValidPlacement: Bool = false
    private var placementIndicator: SKShapeNode! // Visual feedback for placement

    // Scroll state
    private var isScrolling: Bool = false
    private var scrollStartY: CGFloat = 0
    private var initialScrollOffset: CGFloat = 0
    private var touchStartLocation: CGPoint = .zero
    private var potentialFlowerToDrag: FlowerNode?
    private var gestureDecided: Bool = false
    private let scrollThreshold: CGFloat = 10.0 // Movement needed to decide gesture type
    
    // Buttons
    private var bookButton: SKSpriteNode!
    private var settingButton: SKSpriteNode!
    private var resetButton: SKShapeNode!
    private var wrapButton: SKShapeNode!
    private var resetLabel: SKLabelNode!
    private var wrapLabel: SKLabelNode!
    
    // Layout properties
    private var inventoryRect: CGRect!
    private var bouquetRect: CGRect!
    private var chatBoxRect: CGRect!
    
    // Model data
    var storyRequirements: StoryFlowerRequirements?
    var onBouquetWrapped: ((StoryFlowerRequirements.ValidationResult) -> Void)?
    var onBookButtonTapped: (() -> Void)?
    var onSettingButtonTapped: (() -> Void)?
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        // Load default story requirements for testing
        storyRequirements = StoryRequirementsDatabase.shared.getRequirements(for: "story_default")

        // Set up physics
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // No gravity for this game

        setupBackground()
        setupLayout()
        setupChatBox()
        setupBouquet()
        setupInventory()
        setupButtons()
    }
    
    private func setupBackground() {
        // Load and display background image
        if let backgroundTexture = SKTexture(imageNamed: "Background") as SKTexture? {
            backgroundSprite = SKSpriteNode(texture: backgroundTexture)
            backgroundSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
            backgroundSprite.size = size
            backgroundSprite.zPosition = -10
            addChild(backgroundSprite)
        } else {
            // Fallback background color
            backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }
    }
    
    private func setupLayout() {
        let padding: CGFloat = 20
        
        // Left side: Inventory (1 column, scrollable)
        let inventoryWidth: CGFloat = 120
        let inventoryHeight = size.height - 100
        inventoryRect = CGRect(
            x: padding,
            y: 50,
            width: inventoryWidth,
            height: inventoryHeight
        )
        
        // Center: Bouquet area
        let bouquetSize: CGFloat = min(400, size.height * 0.6)
        bouquetRect = CGRect(
            x: (size.width - bouquetSize) / 2,
            y: (size.height - bouquetSize) / 2 - 20,
            width: bouquetSize,
            height: bouquetSize
        )
        
        // Top right: Chat box
        let chatBoxWidth: CGFloat = 400
        let chatBoxHeight: CGFloat = 120
        chatBoxRect = CGRect(
            x: size.width - chatBoxWidth - padding - 80,
            y: size.height - chatBoxHeight - padding - 20,
            width: chatBoxWidth,
            height: chatBoxHeight
        )
    }
    
    private func setupChatBox() {
        // Load chat box image
        if let chatBoxTexture = SKTexture(imageNamed: "ChatBox") as SKTexture? {
            chatBoxNode = SKSpriteNode(texture: chatBoxTexture)
            chatBoxNode.position = CGPoint(
                x: chatBoxRect.midX,
                y: chatBoxRect.midY
            )
            chatBoxNode.size = chatBoxRect.size
            chatBoxNode.zPosition = 50
            addChild(chatBoxNode)
        } else {
            // Fallback to shape
            let chatBoxShape = SKShapeNode(rect: chatBoxRect, cornerRadius: 15)
            chatBoxShape.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 0.95)
            chatBoxShape.strokeColor = UIColor(red: 0.9, green: 0.7, blue: 0.7, alpha: 1.0)
            chatBoxShape.lineWidth = 3
            chatBoxShape.zPosition = 50
            addChild(chatBoxShape)
        }
        
        // Add hint text to chat box
        let hintText = storyRequirements?.hintText ?? "Drag flowers to create your bouquet"
        chatTextNode = SKLabelNode(text: hintText)
        chatTextNode.fontName = "Avenir-Medium"
        chatTextNode.fontSize = 16
        chatTextNode.fontColor = UIColor(red: 0.3, green: 0.2, blue: 0.2, alpha: 1.0)
        chatTextNode.numberOfLines = 3
        chatTextNode.preferredMaxLayoutWidth = chatBoxRect.width - 40
        chatTextNode.verticalAlignmentMode = .center
        chatTextNode.position = CGPoint(x: chatBoxRect.midX, y: chatBoxRect.midY)
        chatTextNode.zPosition = 51
        addChild(chatTextNode)
    }
    
    private func setupBouquet() {
        // Bouquet back image and placement area
        if let backTexture = SKTexture(imageNamed: "BouquetBack") as SKTexture? {
            bouquetBackNode = SKSpriteNode(texture: backTexture)
            bouquetBackNode.position = CGPoint(x: bouquetRect.midX, y: bouquetRect.midY)
            bouquetBackNode.size = CGSize(width: bouquetRect.width * 0.7, height: bouquetRect.height * 0.7)
            bouquetBackNode.zPosition = 10
            addChild(bouquetBackNode)

            // Create invisible placement area with physics body from BACK texture
            // This ensures flowers can only be placed on the back part
            bouquetPlacementArea = SKSpriteNode(texture: backTexture)
            bouquetPlacementArea.position = CGPoint(x: bouquetRect.midX, y: bouquetRect.midY)
            bouquetPlacementArea.size = CGSize(width: bouquetRect.width * 0.7, height: bouquetRect.height * 0.7)
            bouquetPlacementArea.zPosition = 11 // Just above the back image
            bouquetPlacementArea.alpha = 0.0 // Make it invisible

            // Create physics body from BACK texture's alpha channel
            // This creates an accurate hitbox that follows the back's shape
            bouquetPlacementArea.physicsBody = SKPhysicsBody(texture: backTexture, size: bouquetPlacementArea.size)
            bouquetPlacementArea.physicsBody?.isDynamic = false
            bouquetPlacementArea.physicsBody?.categoryBitMask = 0x1
            bouquetPlacementArea.physicsBody?.contactTestBitMask = 0x2
            bouquetPlacementArea.physicsBody?.collisionBitMask = 0
            bouquetPlacementArea.name = "bouquetArea"
            addChild(bouquetPlacementArea)
        }

        // Container for flowers (between back and front)
        bouquetFlowersContainer = SKNode()
        bouquetFlowersContainer.position = CGPoint(x: bouquetRect.midX, y: bouquetRect.midY)
        bouquetFlowersContainer.zPosition = 15
        addChild(bouquetFlowersContainer)

        // Bouquet front image (visual only, no physics)
        if let frontTexture = SKTexture(imageNamed: "BouquetFront") as SKTexture? {
            bouquetFrontNode = SKSpriteNode(texture: frontTexture)
            bouquetFrontNode.position = CGPoint(x: bouquetRect.midX, y: bouquetRect.midY)
            bouquetFrontNode.size = CGSize(width: bouquetRect.width * 0.7, height: bouquetRect.height * 0.7)
            bouquetFrontNode.zPosition = 20
            addChild(bouquetFrontNode)
        }

        // Create placement indicator (initially hidden)
        placementIndicator = SKShapeNode(circleOfRadius: 30)
        placementIndicator.strokeColor = .clear
        placementIndicator.fillColor = UIColor.green.withAlphaComponent(0.3)
        placementIndicator.zPosition = 199
        placementIndicator.isHidden = true
        addChild(placementIndicator)
    }
    
    private func setupInventory() {
        // Create a crop node to mask the inventory area
        inventoryCropNode = SKCropNode()
        inventoryCropNode.position = CGPoint(x: inventoryRect.midX, y: inventoryRect.midY)
        inventoryCropNode.zPosition = 4

        // Create mask shape for the inventory area
        let maskNode = SKShapeNode(rect: CGRect(
            x: -inventoryRect.width / 2,
            y: -inventoryRect.height / 2,
            width: inventoryRect.width,
            height: inventoryRect.height
        ))
        maskNode.fillColor = .white
        inventoryCropNode.maskNode = maskNode

        // Create scroll container
        inventoryScrollNode = SKNode()
        inventoryScrollNode.position = CGPoint(x: 0, y: -inventoryRect.height / 2)
        inventoryScrollNode.zPosition = 5
        inventoryCropNode.addChild(inventoryScrollNode)
        addChild(inventoryCropNode)

        // Add a subtle background for the inventory area
        let inventoryBackground = SKShapeNode(rect: CGRect(
            x: inventoryRect.minX,
            y: inventoryRect.minY,
            width: inventoryRect.width,
            height: inventoryRect.height
        ), cornerRadius: 10)
        inventoryBackground.fillColor = UIColor.white.withAlphaComponent(0.3)
        inventoryBackground.strokeColor = UIColor.gray.withAlphaComponent(0.5)
        inventoryBackground.lineWidth = 1
        inventoryBackground.zPosition = 3
        addChild(inventoryBackground)

        // Get available flowers from database
        let availableFlowers = FlowerDatabase.shared.availableFlowers

        let flowerSize = CGSize(width: 80, height: 80)
        let verticalSpacing: CGFloat = 100

        // Calculate max scroll offset
        let totalHeight = CGFloat(availableFlowers.count) * verticalSpacing
        maxScrollOffset = max(0, totalHeight - inventoryRect.height + 100)

        // Add scroll indicators if there's overflow
        if maxScrollOffset > 0 {
            // Top scroll indicator
            let topIndicator = SKLabelNode(text: "▲")
            topIndicator.fontName = "Avenir-Medium"
            topIndicator.fontSize = 16
            topIndicator.fontColor = UIColor.gray.withAlphaComponent(0.7)
            topIndicator.position = CGPoint(x: inventoryRect.midX, y: inventoryRect.maxY - 20)
            topIndicator.zPosition = 5
            addChild(topIndicator)

            // Bottom scroll indicator
            let bottomIndicator = SKLabelNode(text: "▼")
            bottomIndicator.fontName = "Avenir-Medium"
            bottomIndicator.fontSize = 16
            bottomIndicator.fontColor = UIColor.gray.withAlphaComponent(0.7)
            bottomIndicator.position = CGPoint(x: inventoryRect.midX, y: inventoryRect.minY + 20)
            bottomIndicator.zPosition = 5
            addChild(bottomIndicator)
        }
        
        for (index, flowerData) in availableFlowers.enumerated() {
            // Map flower name to asset name
            let imageName = getFlowerImageName(for: flowerData.flowerName)
            let flower = FlowerNode(flower: flowerData, imageName: imageName, size: flowerSize)
            flower.inventoryIndex = index
            
            // Position in vertical list
            let yPos = inventoryRect.height - 50 - CGFloat(index) * verticalSpacing
            flower.position = CGPoint(x: 0, y: yPos)
            flower.originalPosition = flower.position
            flower.zPosition = 5
            
            // Add label below flower
            let label = SKLabelNode(text: flowerData.flowerName)
            label.fontName = "Avenir-Medium"
            label.fontSize = 12
            label.fontColor = .darkGray
            label.position = CGPoint(x: 0, y: -flowerSize.height / 2 - 15)
            label.zPosition = 1
            flower.addChild(label)
            
            inventoryScrollNode.addChild(flower)
            inventoryFlowers.append(flower)
        }
    }
    
    private func getFlowerImageName(for flowerName: String) -> String {
        // Map flower names to asset names
        switch flowerName {
        case "Rose": return "Rose"
        case "Jasmine": return "Jasmine"
        case "Lavender": return "Lavender"
        case "Hibiscus": return "Hibicus" // Note: asset is named "Hibicus"
        default: return ""
        }
    }
    
    private func setupButtons() {
        let buttonSize: CGFloat = 60
        let buttonSpacing: CGFloat = 20
        let buttonY: CGFloat = 50
        let buttonX = size.width - buttonSize - 30
        
        // Book Button (bottom)
        if let bookTexture = SKTexture(imageNamed: "BookButton") as SKTexture? {
            bookButton = SKSpriteNode(texture: bookTexture)
            bookButton.size = CGSize(width: buttonSize, height: buttonSize)
            bookButton.position = CGPoint(x: buttonX, y: buttonY)
            bookButton.zPosition = 100
            bookButton.name = "bookButton"
            addChild(bookButton)
        }
        
        // Setting Button (above book button)
        if let settingTexture = SKTexture(imageNamed: "SettingButton") as SKTexture? {
            settingButton = SKSpriteNode(texture: settingTexture)
            settingButton.size = CGSize(width: buttonSize, height: buttonSize)
            settingButton.position = CGPoint(x: buttonX, y: buttonY + buttonSize + buttonSpacing)
            settingButton.zPosition = 100
            settingButton.name = "settingButton"
            addChild(settingButton)
        }
        
        // Reset and Wrap buttons (below bouquet)
        let actionButtonWidth: CGFloat = 120
        let actionButtonHeight: CGFloat = 45
        // Ensure buttons are visible by using max to keep them above bottom of screen
        let actionButtonY = max(60, bouquetRect.minY - 60)
        let actionButtonSpacing: CGFloat = 20
        
        // Reset Button
        resetButton = SKShapeNode(rectOf: CGSize(width: actionButtonWidth, height: actionButtonHeight), cornerRadius: 15)
        resetButton.fillColor = UIColor(red: 0.9, green: 0.5, blue: 0.5, alpha: 0.8)
        resetButton.strokeColor = UIColor(red: 0.7, green: 0.3, blue: 0.3, alpha: 1.0)
        resetButton.lineWidth = 3
        resetButton.position = CGPoint(
            x: bouquetRect.midX - actionButtonWidth / 2 - actionButtonSpacing / 2,
            y: actionButtonY
        )
        resetButton.zPosition = 100
        resetButton.name = "resetButton"
        resetButton.alpha = 0.5 // Start disabled
        addChild(resetButton)
        
        resetLabel = SKLabelNode(text: "Reset")
        resetLabel.fontName = "Avenir-Heavy"
        resetLabel.fontSize = 18
        resetLabel.fontColor = .white
        resetLabel.verticalAlignmentMode = .center
        resetLabel.zPosition = 1
        resetButton.addChild(resetLabel)
        
        // Wrap Button
        wrapButton = SKShapeNode(rectOf: CGSize(width: actionButtonWidth, height: actionButtonHeight), cornerRadius: 15)
        wrapButton.fillColor = UIColor(red: 0.5, green: 0.8, blue: 0.6, alpha: 0.9)
        wrapButton.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 0.4, alpha: 1.0)
        wrapButton.lineWidth = 3
        wrapButton.position = CGPoint(
            x: bouquetRect.midX + actionButtonWidth / 2 + actionButtonSpacing / 2,
            y: actionButtonY
        )
        wrapButton.zPosition = 100
        wrapButton.name = "wrapButton"
        wrapButton.alpha = 0.5 // Start disabled
        addChild(wrapButton)
        
        wrapLabel = SKLabelNode(text: "Wrap")
        wrapLabel.fontName = "Avenir-Heavy"
        wrapLabel.fontSize = 18
        wrapLabel.fontColor = .white
        wrapLabel.verticalAlignmentMode = .center
        wrapLabel.zPosition = 1
        wrapButton.addChild(wrapLabel)
    }
    
    private func updateButtonStates() {
        let hasFlowers = !placedFlowers.isEmpty
        
        // Reset button
        if hasFlowers {
            resetButton.fillColor = UIColor(red: 0.9, green: 0.5, blue: 0.5, alpha: 1.0)
            resetButton.alpha = 1.0
        } else {
            resetButton.fillColor = UIColor.gray.withAlphaComponent(0.5)
            resetButton.alpha = 0.5
        }
        
        // Wrap button
        if hasFlowers {
            wrapButton.fillColor = UIColor(red: 0.5, green: 0.8, blue: 0.6, alpha: 1.0)
            wrapButton.alpha = 1.0
        } else {
            wrapButton.fillColor = UIColor.gray.withAlphaComponent(0.5)
            wrapButton.alpha = 0.5
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let touchedNodes = nodes(at: location)

        // Check if touching a button
        for node in touchedNodes {
            if node.name == "resetButton" {
                handleResetButton()
                return
            } else if node.name == "wrapButton" {
                handleWrapButton()
                return
            } else if node.name == "bookButton" {
                handleBookButton()
                return
            } else if node.name == "settingButton" {
                handleSettingButton()
                return
            }
        }

        // Check if we're touching within the inventory area
        if inventoryRect.contains(location) {
            // Store initial touch position
            touchStartLocation = location
            scrollStartY = location.y
            initialScrollOffset = inventoryScrollOffset
            gestureDecided = false

            // Check if we touched an inventory flower
            let inventoryLocation = touch.location(in: inventoryScrollNode)
            for flower in inventoryFlowers {
                if flower.contains(inventoryLocation) {
                    // Store the flower but don't create a copy yet
                    // We'll decide whether to drag or scroll based on movement
                    potentialFlowerToDrag = flower
                    selectedFlower = flower
                    return
                }
            }

            // If no flower was touched, this is definitely a scroll
            isScrolling = true
            gestureDecided = true
            return
        }
        
        // Check if we touched a flower in the bouquet
        let containerLocation = touch.location(in: bouquetFlowersContainer)
        for (index, flower) in placedFlowers.enumerated() {
            if flower.contains(containerLocation) {
                selectedFlower = flower
                isDraggingFromInventory = false
                
                // Remove from placed flowers
                placedFlowers.remove(at: index)
                
                // Move to scene for dragging
                let worldPos = flower.parent!.convert(flower.position, to: self)
                flower.removeFromParent()
                flower.position = worldPos
                flower.zPosition = 200
                flower.setScale(1.2)
                addChild(flower)
                draggedFlowerCopy = flower
                
                updateButtonStates()
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                return
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // If we haven't decided the gesture type yet
        if !gestureDecided && potentialFlowerToDrag != nil {
            let deltaX = abs(location.x - touchStartLocation.x)
            let deltaY = abs(location.y - touchStartLocation.y)

            // Check if movement exceeds threshold
            if deltaX > scrollThreshold || deltaY > scrollThreshold {
                if deltaY > deltaX * 1.5 {
                    // Vertical movement - treat as scroll
                    isScrolling = true
                    gestureDecided = true

                    // Visual feedback: slightly fade the inventory during scroll
                    inventoryScrollNode.run(SKAction.fadeAlpha(to: 0.7, duration: 0.1))
                } else {
                    // Horizontal or diagonal movement - treat as drag
                    gestureDecided = true

                    // Create the flower copy for dragging
                    if let flower = potentialFlowerToDrag {
                        let imageName = getFlowerImageName(for: flower.flowerData.flowerName)
                        draggedFlowerCopy = FlowerNode(flower: flower.flowerData, imageName: imageName, size: flower.size)
                        draggedFlowerCopy!.position = location
                        draggedFlowerCopy!.zPosition = 200
                        draggedFlowerCopy!.setScale(1.0)
                        addChild(draggedFlowerCopy!)

                        isDraggingFromInventory = true

                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
                potentialFlowerToDrag = nil
            }
        }

        // Handle scrolling if we're in scroll mode
        if isScrolling {
            let deltaY = location.y - scrollStartY
            let newOffset = initialScrollOffset + deltaY  // Changed from - to + to fix inversion

            // Apply scroll with bounds checking
            inventoryScrollOffset = min(max(0, newOffset), maxScrollOffset)

            // Update inventory position within the crop node
            inventoryScrollNode.position = CGPoint(
                x: 0,
                y: -inventoryRect.height / 2 + inventoryScrollOffset
            )
            return
        }

        // Handle dragging flower
        guard let draggedFlower = draggedFlowerCopy else { return }
        draggedFlower.position = location

        // Check if the current position is valid using physics
        isValidPlacement = false
        placementIndicator.isHidden = true

        // Check if we're over the bouquet area and not exceeding max flowers
        if placedFlowers.count < maxFlowers || !isDraggingFromInventory {
            // Use physics to check if we're inside the bouquet shape
            let physicsPoint = location
            if let body = physicsWorld.body(at: physicsPoint),
               body == bouquetPlacementArea.physicsBody {
                isValidPlacement = true

                // Show placement indicator
                placementIndicator.position = location
                placementIndicator.fillColor = UIColor.green.withAlphaComponent(0.3)
                placementIndicator.isHidden = false

                // Check for overlap with existing flowers
                let containerLocation = bouquetFlowersContainer.convert(location, from: self)
                for existingFlower in placedFlowers {
                    let distance = hypot(containerLocation.x - existingFlower.position.x,
                                       containerLocation.y - existingFlower.position.y)
                    if distance < 40 { // Minimum spacing between flowers
                        placementIndicator.fillColor = UIColor.yellow.withAlphaComponent(0.3)
                        break
                    }
                }
            } else if bouquetRect.contains(location) {
                // Near the bouquet but not in valid area
                placementIndicator.position = location
                placementIndicator.fillColor = UIColor.red.withAlphaComponent(0.3)
                placementIndicator.isHidden = false
            }
        } else {
            // Max flowers reached
            if bouquetRect.contains(location) {
                placementIndicator.position = location
                placementIndicator.fillColor = UIColor.orange.withAlphaComponent(0.3)
                placementIndicator.isHidden = false
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        // Reset gesture state
        potentialFlowerToDrag = nil
        gestureDecided = false

        // End scrolling if we were scrolling
        if isScrolling {
            isScrolling = false
            // Restore full opacity
            inventoryScrollNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.1))
            return
        }

        // Handle flower placement
        guard let draggedFlower = draggedFlowerCopy else { return }
        let location = touch.location(in: self)
        placementIndicator.isHidden = true

        // Check if we can place the flower using physics validation
        if isValidPlacement && (placedFlowers.count < maxFlowers || !isDraggingFromInventory) {
            // Place the flower at the exact position (freeform placement)
            draggedFlower.removeFromParent()

            // Convert position to container coordinates
            let containerLocation = bouquetFlowersContainer.convert(location, from: self)
            draggedFlower.position = containerLocation

            // Dynamic z-ordering based on y-position (flowers at bottom appear in front)
            let normalizedY = (containerLocation.y + 150) / 300 // Normalize to 0-1 range
            let zPosition = (1 - normalizedY) * 5 // Higher z for lower flowers, but within container bounds
            draggedFlower.zPosition = zPosition

            // Scale based on distance from center for depth effect
            let distanceFromCenter = hypot(containerLocation.x, containerLocation.y)
            let scaleFactor = 0.7 + (1 - min(distanceFromCenter / 150, 1)) * 0.3
            draggedFlower.setScale(scaleFactor)

            bouquetFlowersContainer.addChild(draggedFlower)
            placedFlowers.append(draggedFlower)

            // Success feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // Gentle placement animation
            let bounce = SKAction.sequence([
                SKAction.scale(to: scaleFactor * 1.1, duration: 0.1),
                SKAction.scale(to: scaleFactor, duration: 0.1)
            ])
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -0.1...0.1), duration: 0.2)
            draggedFlower.run(SKAction.group([bounce, rotate]))

            updateButtonStates()
        } else {
            // Invalid placement - return flower with animation
            if isDraggingFromInventory {
                // Animate back to inventory
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let scaleDown = SKAction.scale(to: 0.1, duration: 0.2)
                let remove = SKAction.removeFromParent()
                draggedFlower.run(SKAction.sequence([
                    SKAction.group([fadeOut, scaleDown]),
                    remove
                ]))
            } else {
                // It was from bouquet, just remove
                draggedFlower.removeFromParent()
            }

            // Error feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }

        // Reset drag state
        draggedFlowerCopy = nil
        selectedFlower = nil
        isDraggingFromInventory = false
        isValidPlacement = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggedFlowerCopy?.removeFromParent()
        draggedFlowerCopy = nil
        selectedFlower = nil
        isDraggingFromInventory = false
        isValidPlacement = false
        placementIndicator.isHidden = true

        if isScrolling {
            inventoryScrollNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.1))
        }
        isScrolling = false
        potentialFlowerToDrag = nil
        gestureDecided = false
    }
    
    // MARK: - Button Handlers
    private func handleResetButton() {
        guard !placedFlowers.isEmpty else { return }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animate button press
        resetButton.run(SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        // Remove all flowers
        for flower in placedFlowers {
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.2)
            let remove = SKAction.removeFromParent()
            flower.run(SKAction.sequence([
                SKAction.group([fadeOut, scaleDown]),
                remove
            ]))
        }
        
        placedFlowers.removeAll()
        updateButtonStates()
    }
    
    private func handleWrapButton() {
        guard !placedFlowers.isEmpty else { return }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Animate button press
        wrapButton.run(SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        // Collect flowers from bouquet
        var bouquetFlowers: [Flower] = []
        for flower in placedFlowers {
            bouquetFlowers.append(flower.flowerData)
        }
        
        // Validate bouquet
        if let requirements = storyRequirements {
            let result = requirements.validate(bouquet: bouquetFlowers)
            showValidationResult(result)
            
            // Call callback if set
            onBouquetWrapped?(result)
        }
    }
    
    private func handleBookButton() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Animate button press
        bookButton.run(SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        // Call callback if set
        onBookButtonTapped?()
    }
    
    private func handleSettingButton() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Animate button press
        settingButton.run(SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        // Call callback if set
        onSettingButtonTapped?()
    }
    
    private func showValidationResult(_ result: StoryFlowerRequirements.ValidationResult) {
        var message: String
        var color: UIColor
        var hapticType: UINotificationFeedbackGenerator.FeedbackType

        switch result {
        case .perfectMatch:
            message = "Perfect Match!"
            color = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
            hapticType = .success

            // Add sparkle effect
            addSparkleEffect()

        case .goodMatch:
            message = "Good Match!"
            color = UIColor(red: 0.3, green: 0.6, blue: 0.8, alpha: 1.0)
            hapticType = .success

        case .failure(let failureMessage, let missingEmotions):
            message = "\(failureMessage)"
            color = UIColor(red: 0.9, green: 0.6, blue: 0.3, alpha: 1.0)
            hapticType = .warning

            print("Missing emotions: \(missingEmotions.joined(separator: ", "))")
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(hapticType)
        
        // Show result label
        let resultLabel = SKLabelNode(text: message)
        resultLabel.fontName = "Avenir-Heavy"
        resultLabel.fontSize = 32
        resultLabel.fontColor = color
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        resultLabel.zPosition = 250
        resultLabel.alpha = 0
        addChild(resultLabel)
        
        // Animate result
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        resultLabel.run(SKAction.sequence([
            SKAction.group([fadeIn, scale]),
            wait,
            fadeOut,
            remove
        ]))
    }
    
    private func addSparkleEffect() {
        // Add sparkles around the bouquet area
        for _ in 0..<15 {
            let sparkle = SKShapeNode(circleOfRadius: 4)
            sparkle.fillColor = .yellow
            sparkle.strokeColor = .orange
            sparkle.position = CGPoint(
                x: bouquetRect.midX + CGFloat.random(in: -150...150),
                y: bouquetRect.midY + CGFloat.random(in: -150...150)
            )
            sparkle.zPosition = 150
            addChild(sparkle)
            
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let scaleUp = SKAction.scale(to: 2.0, duration: 1.0)
            let remove = SKAction.removeFromParent()
            
            sparkle.run(SKAction.sequence([
                SKAction.group([fadeOut, scaleUp]),
                remove
            ]))
        }
    }
    
    // MARK: - Public Methods
    func setStoryRequirements(_ requirements: StoryFlowerRequirements) {
        self.storyRequirements = requirements
        chatTextNode?.text = requirements.hintText
    }
    
    func getCurrentBouquet() -> [Flower] {
        return placedFlowers.map { $0.flowerData }
    }
    
    // MARK: - Helper Methods
    private func canPlaceFlower(at position: CGPoint, excludingFlower: FlowerNode? = nil) -> Bool {
        // Check if position is within bouquet physics body
        let worldPosition = bouquetFlowersContainer.convert(position, to: self)
        guard let body = physicsWorld.body(at: worldPosition),
              body == bouquetPlacementArea.physicsBody else {
            return false
        }

        // Check minimum spacing with other flowers
        let minSpacing: CGFloat = 35 // Minimum distance between flower centers
        for flower in placedFlowers {
            if flower === excludingFlower { continue }
            let distance = hypot(position.x - flower.position.x, position.y - flower.position.y)
            if distance < minSpacing {
                return false
            }
        }

        return true
    }

    private func sortFlowersByDepth() {
        // Sort flowers in container by their y-position for proper layering
        let sortedFlowers = placedFlowers.sorted { flower1, flower2 in
            return flower1.position.y > flower2.position.y
        }

        // Update z-positions based on sort order (keep within 0-5 range)
        for (index, flower) in sortedFlowers.enumerated() {
            flower.zPosition = CGFloat(index) * 0.1 // Small increments to maintain order
        }
    }

    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        // Future: Add animations if needed
    }
}
