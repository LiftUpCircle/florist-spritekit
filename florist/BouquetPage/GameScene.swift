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
class GameScene: SKScene {
    
    // Background
    private var backgroundSprite: SKSpriteNode!
    
    // UI Areas
    private var inventoryScrollNode: SKNode!
    private var chatBoxNode: SKSpriteNode!
    private var chatTextNode: SKLabelNode!
    
    // Bouquet images
    private var bouquetBackNode: SKSpriteNode!
    private var bouquetFrontNode: SKSpriteNode!
    private var bouquetFlowersContainer: SKNode!
    
    // Inventory flowers (original templates)
    private var inventoryFlowers: [FlowerNode] = []
    private var inventoryScrollOffset: CGFloat = 0
    private var maxScrollOffset: CGFloat = 0
    
    // Bouquet slots (invisible, for positioning flowers)
    private var bouquetSlots: [CGPoint] = []
    private var placedFlowers: [FlowerNode] = []
    private let maxSlots = 6
    
    // Drag state
    private var selectedFlower: FlowerNode?
    private var isDraggingFromInventory: Bool = false
    private var draggedFlowerCopy: FlowerNode?
    private var nearestSlotIndex: Int? = nil
    
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
        // Container for flowers (between back and front)
        bouquetFlowersContainer = SKNode()
        bouquetFlowersContainer.position = CGPoint(x: bouquetRect.midX, y: bouquetRect.midY)
        bouquetFlowersContainer.zPosition = 15
        addChild(bouquetFlowersContainer)
        
        // Bouquet back image
        if let backTexture = SKTexture(imageNamed: "BouquetBack") as SKTexture? {
            bouquetBackNode = SKSpriteNode(texture: backTexture)
            bouquetBackNode.position = CGPoint(x: bouquetRect.midX, y: bouquetRect.midY)
            bouquetBackNode.size = CGSize(width: bouquetRect.width * 0.7, height: bouquetRect.height * 0.7)
            bouquetBackNode.zPosition = 10
            addChild(bouquetBackNode)
        }
        
        // Bouquet front image
        if let frontTexture = SKTexture(imageNamed: "BouquetFront") as SKTexture? {
            bouquetFrontNode = SKSpriteNode(texture: frontTexture)
            bouquetFrontNode.position = CGPoint(x: bouquetRect.midX, y: bouquetRect.midY)
            bouquetFrontNode.size = CGSize(width: bouquetRect.width * 0.7, height: bouquetRect.height * 0.7)
            bouquetFrontNode.zPosition = 20
            addChild(bouquetFrontNode)
        }
        
        // Define slot positions for flowers (relative to bouquet center)
        // Arrange in 2 rows of 3
        let slotSpacingX: CGFloat = 60
        let slotSpacingY: CGFloat = 50
        let startX: CGFloat = -slotSpacingX
        let startY: CGFloat = 20
        
        for row in 0..<2 {
            for col in 0..<3 {
                let slotPos = CGPoint(
                    x: startX + CGFloat(col) * slotSpacingX,
                    y: startY - CGFloat(row) * slotSpacingY
                )
                bouquetSlots.append(slotPos)
            }
        }
    }
    
    private func setupInventory() {
        // Create scroll container
        inventoryScrollNode = SKNode()
        inventoryScrollNode.position = CGPoint(x: inventoryRect.midX, y: inventoryRect.minY)
        inventoryScrollNode.zPosition = 5
        addChild(inventoryScrollNode)
        
        // Get available flowers from database
        let availableFlowers = FlowerDatabase.shared.availableFlowers
        
        let flowerSize = CGSize(width: 80, height: 80)
        let verticalSpacing: CGFloat = 100
        
        // Calculate max scroll offset
        let totalHeight = CGFloat(availableFlowers.count) * verticalSpacing
        maxScrollOffset = max(0, totalHeight - inventoryRect.height + 100)
        
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
        let actionButtonY = bouquetRect.minY - 70
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
        
        // Check if we touched an inventory flower
        let inventoryLocation = touch.location(in: inventoryScrollNode)
        for flower in inventoryFlowers {
            if flower.contains(inventoryLocation) {
                // Create a copy for dragging
                let imageName = getFlowerImageName(for: flower.flowerData.flowerName)
                draggedFlowerCopy = FlowerNode(flower: flower.flowerData, imageName: imageName, size: flower.size)
                draggedFlowerCopy!.position = location
                draggedFlowerCopy!.zPosition = 200
                draggedFlowerCopy!.setScale(1.0)
                addChild(draggedFlowerCopy!)
                
                isDraggingFromInventory = true
                selectedFlower = flower
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                return
            }
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
        guard let touch = touches.first,
              let draggedFlower = draggedFlowerCopy else { return }
        
        let location = touch.location(in: self)
        draggedFlower.position = location
        
        // Find nearest slot
        let containerLocation = touch.location(in: bouquetFlowersContainer)
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        var foundSlotIndex: Int? = nil
        
        for (index, slotPos) in bouquetSlots.enumerated() {
            // Skip occupied slots
            if placedFlowers.count >= maxSlots && isDraggingFromInventory { continue }
            
            let distance = hypot(containerLocation.x - slotPos.x, containerLocation.y - slotPos.y)
            if distance < minDistance && distance < 80 {
                minDistance = distance
                foundSlotIndex = index
            }
        }
        
        nearestSlotIndex = foundSlotIndex
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let draggedFlower = draggedFlowerCopy else { return }
        
        let location = touch.location(in: self)
        
        // Check if we can place in bouquet
        if bouquetRect.contains(location) && placedFlowers.count < maxSlots {
            // Place the flower in the bouquet
            draggedFlower.removeFromParent()
            
            // Position at nearest slot or center if no slot found
            let slotPosition: CGPoint
            if let slotIndex = nearestSlotIndex {
                slotPosition = bouquetSlots[slotIndex]
            } else if !bouquetSlots.isEmpty {
                // Find first available slot based on count
                let slotIndex = min(placedFlowers.count, bouquetSlots.count - 1)
                slotPosition = bouquetSlots[slotIndex]
            } else {
                slotPosition = .zero
            }
            
            draggedFlower.position = slotPosition
            draggedFlower.setScale(0.8)
            draggedFlower.zPosition = CGFloat(placedFlowers.count)
            bouquetFlowersContainer.addChild(draggedFlower)
            placedFlowers.append(draggedFlower)
            
            // Success feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Gentle bounce
            let bounce = SKAction.sequence([
                SKAction.scale(to: 0.9, duration: 0.1),
                SKAction.scale(to: 0.8, duration: 0.1)
            ])
            draggedFlower.run(bounce)
            
            updateButtonStates()
        } else {
            // Remove the dragged copy if not placed
            draggedFlower.removeFromParent()
        }
        
        // Reset drag state
        draggedFlowerCopy = nil
        selectedFlower = nil
        isDraggingFromInventory = false
        nearestSlotIndex = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggedFlowerCopy?.removeFromParent()
        draggedFlowerCopy = nil
        selectedFlower = nil
        isDraggingFromInventory = false
        nearestSlotIndex = nil
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
            message = "✨ Perfect Match! ✨"
            color = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
            hapticType = .success
            
            // Add sparkle effect
            addSparkleEffect()
            
        case .goodMatch:
            message = "💐 Good Match!"
            color = UIColor(red: 0.3, green: 0.6, blue: 0.8, alpha: 1.0)
            hapticType = .success
            
        case .failure(let failureMessage, let missingEmotions):
            message = "💬 \(failureMessage)"
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
    
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        // Future: Add animations if needed
    }
}
