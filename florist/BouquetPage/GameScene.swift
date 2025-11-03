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
    
    init(flower: Flower, size: CGSize) {
        self.flowerData = flower
        super.init(texture: nil, color: flower.flowerColor, size: size)
        self.name = "flower_\(flower.flowerName)"
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Create a copy of this flower node
    func createCopy() -> FlowerNode {
        let copy = FlowerNode(flower: flowerData, size: self.size)
        copy.isInInventory = false
        
        // Copy visual children
        for child in self.children {
            if let childCopy = child.copy() as? SKNode {
                copy.addChild(childCopy)
            }
        }
        
        return copy
    }
}

// MARK: - Game Scene
class GameScene: SKScene {
    
    // UI Areas
    private var inventoryArea: SKShapeNode!
    private var bouquetWorkstationArea: SKShapeNode!
    private var backgroundNode: SKShapeNode!
    
    // Inventory flowers (original templates)
    private var inventoryFlowers: [FlowerNode] = []
    
    // Bouquet slots
    private var bouquetSlots: [BouquetSlot] = []
    private let maxSlots = 6
    
    // Drag state
    private var selectedFlower: FlowerNode?
    private var isDraggingFromInventory: Bool = false
    private var draggedFlowerCopy: FlowerNode?
    private var hoveredSlot: BouquetSlot?
    
    // Buttons
    private var resetButton: SKShapeNode!
    private var wrapButton: SKShapeNode!
    private var resetLabel: SKLabelNode!
    private var wrapLabel: SKLabelNode!
    
    // Hint text
    private var hintTextNode: SKLabelNode!
    
    // Layout properties
    private var inventoryRect: CGRect!
    private var workstationRect: CGRect!
    
    // Model data
    var storyRequirements: StoryFlowerRequirements?
    var onBouquetWrapped: ((StoryFlowerRequirements.ValidationResult) -> Void)?
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        // Load default story requirements for testing
        storyRequirements = StoryRequirementsDatabase.shared.getRequirements(for: "story_default")
        
        setupBackground()
        setupLayout()
        setupUI()
        setupInventoryFlowers()
        setupBouquetSlots()
        setupButtons()
        setupHintText()
        updateButtonStates()
    }
    
    private func setupBackground() {
        // Soft pastel background for a calming feel
        backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        
        // Add a subtle gradient effect using a shape
        backgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        backgroundNode.fillColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0)
        backgroundNode.strokeColor = .clear
        backgroundNode.position = .zero
        backgroundNode.zPosition = -10
        addChild(backgroundNode)
    }
    
    private func setupLayout() {
        let padding: CGFloat = 20
        let bottomSafeArea: CGFloat = 80 // Safe area for buttons
        let topSafeArea: CGFloat = 60 // Safe area for hint text
        
        // Calculate areas for landscape orientation
        // Left side: Inventory (28%), Right side: Bouquet Workstation (58%)
        let inventoryWidth = size.width * 0.28
        let workstationWidth = size.width * 0.58
        
        // Calculate available height (excluding safe areas)
        let availableHeight = size.height - topSafeArea - bottomSafeArea
        
        inventoryRect = CGRect(
            x: padding,
            y: bottomSafeArea + 10,
            width: inventoryWidth,
            height: availableHeight - 20
        )
        
        workstationRect = CGRect(
            x: size.width - workstationWidth - padding,
            y: bottomSafeArea + availableHeight * 0.15,
            width: workstationWidth,
            height: availableHeight * 0.70
        )
    }
    
    private func setupUI() {
        // Inventory Panel
        inventoryArea = SKShapeNode(rect: inventoryRect, cornerRadius: 20)
        inventoryArea.fillColor = UIColor(red: 0.9, green: 0.95, blue: 0.9, alpha: 0.85)
        inventoryArea.strokeColor = UIColor(red: 0.6, green: 0.8, blue: 0.6, alpha: 0.9)
        inventoryArea.lineWidth = 3
        inventoryArea.zPosition = 1
        addChild(inventoryArea)
        
        // Inventory Label
        let inventoryLabel = SKLabelNode(text: "🌸 Flower Inventory")
        inventoryLabel.fontName = "Avenir-Heavy"
        inventoryLabel.fontSize = 20
        inventoryLabel.fontColor = UIColor(red: 0.3, green: 0.5, blue: 0.3, alpha: 1.0)
        inventoryLabel.position = CGPoint(
            x: inventoryRect.midX,
            y: inventoryRect.maxY + 20
        )
        inventoryLabel.zPosition = 2
        addChild(inventoryLabel)
        
        // Bouquet Workstation Area
        bouquetWorkstationArea = SKShapeNode(rect: workstationRect, cornerRadius: 25)
        bouquetWorkstationArea.fillColor = UIColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 0.92)
        bouquetWorkstationArea.strokeColor = UIColor(red: 0.9, green: 0.7, blue: 0.7, alpha: 1.0)
        bouquetWorkstationArea.lineWidth = 4
        bouquetWorkstationArea.zPosition = 1
        addChild(bouquetWorkstationArea)
        
        // Workstation Label
        let workstationLabel = SKLabelNode(text: "💐 Your Bouquet")
        workstationLabel.fontName = "Avenir-Heavy"
        workstationLabel.fontSize = 22
        workstationLabel.fontColor = UIColor(red: 0.6, green: 0.3, blue: 0.4, alpha: 1.0)
        workstationLabel.position = CGPoint(
            x: workstationRect.midX,
            y: workstationRect.maxY + 30
        )
        workstationLabel.zPosition = 2
        addChild(workstationLabel)
    }
    
    private func setupInventoryFlowers() {
        // Get available flowers from database
        let availableFlowers = FlowerDatabase.shared.availableFlowers
        
        let flowerSize = CGSize(width: 45, height: 60)
        let columns = 2
        let rows = Int(ceil(Double(availableFlowers.count) / Double(columns)))
        
        // Calculate spacing to fit within inventory area
        let availableWidth = inventoryRect.width - 40
        let availableHeight = inventoryRect.height - 60 // Reserve space for title
        let spacingX: CGFloat = availableWidth / CGFloat(columns)
        let spacingY: CGFloat = min(95, availableHeight / CGFloat(rows))
        
        let startX = inventoryRect.minX + spacingX / 2
        let startY = inventoryRect.maxY - 55
        
        for (index, flowerData) in availableFlowers.enumerated() {
            let row = index / columns
            let col = index % columns
            
            let flower = FlowerNode(flower: flowerData, size: flowerSize)
            flower.inventoryIndex = index
            
            // Position in inventory grid
            let xPos = startX + (CGFloat(col) * spacingX)
            let yPos = startY - (CGFloat(row) * spacingY)
            flower.position = CGPoint(x: xPos, y: yPos)
            flower.originalPosition = flower.position
            flower.zPosition = 5
            
            // Add flower visual
            addFlowerShape(to: flower)
            
            // Add label
            let label = SKLabelNode(text: flowerData.flowerName)
            label.fontName = "Avenir-Medium"
            label.fontSize = 9
            label.fontColor = .darkGray
            label.position = CGPoint(x: 0, y: -flowerSize.height / 2 - 12)
            label.zPosition = 1
            flower.addChild(label)
            
            addChild(flower)
            inventoryFlowers.append(flower)
        }
    }
    
    private func setupBouquetSlots() {
        let slotSize = CGSize(width: 65, height: 82)
        let columns = 3
        let rows = 2
        
        let totalWidth = CGFloat(columns) * slotSize.width + CGFloat(columns - 1) * 22
        let totalHeight = CGFloat(rows) * slotSize.height + CGFloat(rows - 1) * 20
        
        let startX = workstationRect.midX - totalWidth / 2 + slotSize.width / 2
        let startY = workstationRect.midY + totalHeight / 2 - slotSize.height / 2 + 10
        
        let spacingX: CGFloat = slotSize.width + 22
        let spacingY: CGFloat = slotSize.height + 20
        
        for i in 0..<maxSlots {
            let row = i / columns
            let col = i % columns
            
            let slot = BouquetSlot(index: i, size: slotSize)
            let xPos = startX + (CGFloat(col) * spacingX)
            let yPos = startY - (CGFloat(row) * spacingY)
            slot.position = CGPoint(x: xPos, y: yPos)
            slot.zPosition = 3
            
            addChild(slot)
            bouquetSlots.append(slot)
        }
    }
    
    private func setupButtons() {
        let buttonWidth: CGFloat = 130
        let buttonHeight: CGFloat = 45
        let buttonY = workstationRect.minY - 60
        let spacing: CGFloat = 15
        
        // Reset Button
        resetButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 15)
        resetButton.fillColor = UIColor(red: 0.9, green: 0.5, blue: 0.5, alpha: 0.8)
        resetButton.strokeColor = UIColor(red: 0.7, green: 0.3, blue: 0.3, alpha: 1.0)
        resetButton.lineWidth = 3
        resetButton.position = CGPoint(
            x: workstationRect.midX - buttonWidth / 2 - spacing / 2,
            y: buttonY
        )
        resetButton.zPosition = 10
        resetButton.name = "resetButton"
        addChild(resetButton)
        
        resetLabel = SKLabelNode(text: "Reset")
        resetLabel.fontName = "Avenir-Heavy"
        resetLabel.fontSize = 18
        resetLabel.fontColor = .white
        resetLabel.verticalAlignmentMode = .center
        resetLabel.zPosition = 11
        resetButton.addChild(resetLabel)
        
        // Wrap Flower Button
        wrapButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 15)
        wrapButton.fillColor = UIColor(red: 0.5, green: 0.8, blue: 0.6, alpha: 0.9)
        wrapButton.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 0.4, alpha: 1.0)
        wrapButton.lineWidth = 3
        wrapButton.position = CGPoint(
            x: workstationRect.midX + buttonWidth / 2 + spacing / 2,
            y: buttonY
        )
        wrapButton.zPosition = 10
        wrapButton.name = "wrapButton"
        addChild(wrapButton)
        
        wrapLabel = SKLabelNode(text: "Wrap Flower")
        wrapLabel.fontName = "Avenir-Heavy"
        wrapLabel.fontSize = 16
        wrapLabel.fontColor = .white
        wrapLabel.verticalAlignmentMode = .center
        wrapLabel.zPosition = 11
        wrapButton.addChild(wrapLabel)
    }
    
    private func setupHintText() {
        let hintText = storyRequirements?.hintText ?? "Drag flowers to create your bouquet"
        
        hintTextNode = SKLabelNode(text: hintText)
        hintTextNode.fontName = "Avenir-BookOblique"
        hintTextNode.fontSize = 15
        hintTextNode.fontColor = UIColor.darkGray.withAlphaComponent(0.8)
        hintTextNode.position = CGPoint(
            x: size.width / 2,
            y: size.height - 30
        )
        hintTextNode.zPosition = 10
        
        // TODO: Add colored highlights based on requirements
        addChild(hintTextNode)
    }
    
    private func addFlowerShape(to flower: FlowerNode) {
        // Create a simple flower representation
        let petalCount = 5
        let petalRadius: CGFloat = 18
        let centerRadius: CGFloat = 10
        
        // Petals
        for i in 0..<petalCount {
            let angle = (CGFloat(i) * 2 * .pi) / CGFloat(petalCount) - .pi / 2
            let petal = SKShapeNode(circleOfRadius: petalRadius)
            petal.fillColor = flower.flowerData.flowerColor
            petal.strokeColor = flower.flowerData.flowerColor.withAlphaComponent(0.8)
            petal.lineWidth = 2
            petal.position = CGPoint(
                x: cos(angle) * centerRadius,
                y: sin(angle) * centerRadius + 8
            )
            petal.zPosition = -1
            flower.addChild(petal)
        }
        
        // Center
        let center = SKShapeNode(circleOfRadius: centerRadius)
        center.fillColor = UIColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0)
        center.strokeColor = UIColor.orange
        center.lineWidth = 2
        center.position = CGPoint(x: 0, y: 8)
        flower.addChild(center)
        
        // Stem
        let stemPath = UIBezierPath()
        stemPath.move(to: CGPoint(x: 0, y: 0))
        stemPath.addLine(to: CGPoint(x: 0, y: -28))
        let stem = SKShapeNode(path: stemPath.cgPath)
        stem.strokeColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        stem.lineWidth = 3
        flower.addChild(stem)
    }
    
    private func updateButtonStates() {
        let hasFlowers = bouquetSlots.contains { $0.isOccupied }
        
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
            }
        }
        
        // Check if we touched an inventory flower
        for flower in inventoryFlowers {
            if flower.contains(location) {
                // Create a copy for dragging
                draggedFlowerCopy = flower.createCopy()
                draggedFlowerCopy!.position = location
                draggedFlowerCopy!.zPosition = 100
                draggedFlowerCopy!.setScale(1.1)
                addChild(draggedFlowerCopy!)
                
                isDraggingFromInventory = true
                selectedFlower = flower
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                return
            }
        }
        
        // Check if we touched a flower in a slot
        for slot in bouquetSlots {
            if slot.isOccupied, let flower = slot.placedFlower, slot.contains(location) {
                selectedFlower = flower
                isDraggingFromInventory = false
                
                // Remove from slot
                if let removedFlower = slot.removeFlower() {
                    removedFlower.position = location
                    removedFlower.zPosition = 100
                    removedFlower.setScale(1.1)
                    addChild(removedFlower)
                    draggedFlowerCopy = removedFlower
                }
                
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
        
        // Find which slot we're hovering over
        var foundSlot: BouquetSlot? = nil
        for slot in bouquetSlots {
            if slot.contains(location) && !slot.isOccupied {
                foundSlot = slot
                break
            }
        }
        
        // Update hover state
        if let newHoveredSlot = foundSlot, newHoveredSlot !== hoveredSlot {
            hoveredSlot?.unhighlightSlot()
            newHoveredSlot.highlightSlot()
            hoveredSlot = newHoveredSlot
        } else if foundSlot == nil && hoveredSlot != nil {
            hoveredSlot?.unhighlightSlot()
            hoveredSlot = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let draggedFlower = draggedFlowerCopy else { return }
        
        let location = touch.location(in: self)
        
        // Unhighlight any hovered slot
        hoveredSlot?.unhighlightSlot()
        hoveredSlot = nil
        
        // Try to place in a slot
        var placed = false
        for slot in bouquetSlots {
            if slot.contains(location) && !slot.isOccupied {
                // Place the flower in the slot
                draggedFlower.removeFromParent()
                draggedFlower.setScale(0.95) // Slightly smaller in slot
                slot.placeFlower(draggedFlower)
                placed = true
                
                // Success feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // Gentle bounce
                let bounce = SKAction.sequence([
                    SKAction.scale(to: 1.05, duration: 0.1),
                    SKAction.scale(to: 0.95, duration: 0.1)
                ])
                draggedFlower.run(bounce)
                
                updateButtonStates()
                break
            }
        }
        
        // If not placed in a slot, remove the copy
        if !placed {
            draggedFlower.removeFromParent()
        }
        
        // Reset drag state
        draggedFlowerCopy = nil
        selectedFlower = nil
        isDraggingFromInventory = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggedFlowerCopy?.removeFromParent()
        draggedFlowerCopy = nil
        selectedFlower = nil
        isDraggingFromInventory = false
        hoveredSlot?.unhighlightSlot()
        hoveredSlot = nil
    }
    
    // MARK: - Button Handlers
    private func handleResetButton() {
        let hasFlowers = bouquetSlots.contains { $0.isOccupied }
        guard hasFlowers else { return }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animate button press
        resetButton.run(SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        // Remove all flowers from slots
        for slot in bouquetSlots {
            if let flower = slot.removeFlower() {
                // Animate flower removal
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let scaleDown = SKAction.scale(to: 0.1, duration: 0.2)
                let remove = SKAction.removeFromParent()
                flower.run(SKAction.sequence([
                    SKAction.group([fadeOut, scaleDown]),
                    remove
                ]))
            }
        }
        
        updateButtonStates()
    }
    
    private func handleWrapButton() {
        let hasFlowers = bouquetSlots.contains { $0.isOccupied }
        guard hasFlowers else { return }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Animate button press
        wrapButton.run(SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
        // Collect flowers from slots
        var bouquetFlowers: [Flower] = []
        for slot in bouquetSlots {
            if let flower = slot.placedFlower {
                bouquetFlowers.append(flower.flowerData)
            }
        }
        
        // Validate bouquet
        if let requirements = storyRequirements {
            let result = requirements.validate(bouquet: bouquetFlowers)
            showValidationResult(result)
            
            // Call callback if set
            onBouquetWrapped?(result)
        }
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
        resultLabel.zPosition = 200
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
                x: workstationRect.midX + CGFloat.random(in: -150...150),
                y: workstationRect.midY + CGFloat.random(in: -150...150)
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
        hintTextNode?.text = requirements.hintText
    }
    
    func getCurrentBouquet() -> [Flower] {
        var bouquet: [Flower] = []
        for slot in bouquetSlots {
            if let flower = slot.placedFlower {
                bouquet.append(flower.flowerData)
            }
        }
        return bouquet
    }
    
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        // Future: Add gentle floating animation to flowers
    }
}
