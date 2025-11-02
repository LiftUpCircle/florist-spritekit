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
    var flowerType: String
    
    init(type: String, color: UIColor, size: CGSize) {
        self.flowerType = type
        super.init(texture: nil, color: color, size: size)
        self.name = "flower_\(type)"
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Game Scene
class GameScene: SKScene {
    
    // UI Areas
    private var inventoryArea: SKShapeNode!
    private var bouquetArea: SKShapeNode!
    private var backgroundNode: SKShapeNode!

    // Flowers
    private var flowers: [FlowerNode] = []
    private var selectedFlower: FlowerNode?

    // Layout properties
    private var inventoryRect: CGRect!
    private var bouquetRect: CGRect!

    // Animation properties
    private var inventoryOffscreenPosition: CGPoint!
    private var inventoryOnscreenPosition: CGPoint!
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupBackground()
        setupLayout()
        setupUI()
        setupFlowers()
        addInstructions()

        // Animate inventory sliding in from the left
        animateInventoryIn()
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
        let padding: CGFloat = 40
        let middleGap: CGFloat = 60
        
        // Calculate areas for landscape orientation
        // Left side: Inventory, Right side: Bouquet area
        let inventoryWidth = size.width * 0.35
        let bouquetWidth = size.width * 0.45
        
        inventoryRect = CGRect(
            x: padding,
            y: padding,
            width: inventoryWidth,
            height: size.height - (padding * 2)
        )
        
        bouquetRect = CGRect(
            x: size.width - bouquetWidth - padding,
            y: size.height * 0.2,
            width: bouquetWidth,
            height: size.height * 0.6
        )
    }
    
    private func setupUI() {
        // Calculate positions for animation
        inventoryOnscreenPosition = CGPoint(x: inventoryRect.midX, y: inventoryRect.midY)
        inventoryOffscreenPosition = CGPoint(x: -inventoryRect.width, y: inventoryRect.midY)

        // Inventory Panel - Start off-screen
        inventoryArea = SKShapeNode(rect: CGRect(origin: CGPoint(x: -inventoryRect.width / 2, y: -inventoryRect.height / 2),
                                                  size: CGSize(width: inventoryRect.width, height: inventoryRect.height)),
                                     cornerRadius: 20)
        inventoryArea.fillColor = UIColor(red: 0.9, green: 0.95, blue: 0.9, alpha: 0.8)
        inventoryArea.strokeColor = UIColor(red: 0.6, green: 0.8, blue: 0.6, alpha: 0.8)
        inventoryArea.lineWidth = 3
        inventoryArea.zPosition = 1
        inventoryArea.position = inventoryOffscreenPosition
        inventoryArea.alpha = 0.0  // Start invisible
        addChild(inventoryArea)

        // Inventory Label
        let inventoryLabel = SKLabelNode(text: "🌸 Flower Inventory")
        inventoryLabel.fontName = "Avenir-Heavy"
        inventoryLabel.fontSize = 24
        inventoryLabel.fontColor = UIColor(red: 0.3, green: 0.5, blue: 0.3, alpha: 1.0)
        inventoryLabel.position = CGPoint(x: 0, y: inventoryRect.height / 2 - 40)
        inventoryLabel.zPosition = 2
        inventoryLabel.name = "inventoryLabel"
        inventoryArea.addChild(inventoryLabel)
        
        // Bouquet Area
        bouquetArea = SKShapeNode(rect: bouquetRect, cornerRadius: 25)
        bouquetArea.fillColor = UIColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 0.9)
        bouquetArea.strokeColor = UIColor(red: 0.8, green: 0.6, blue: 0.6, alpha: 0.8)
        bouquetArea.lineWidth = 4
        bouquetArea.strokeColor = UIColor(red: 0.9, green: 0.7, blue: 0.7, alpha: 1.0)
        bouquetArea.setScale(1.0)
        bouquetArea.zPosition = 1
        addChild(bouquetArea)
        
        // Bouquet Label
        let bouquetLabel = SKLabelNode(text: "💐 Your Bouquet")
        bouquetLabel.fontName = "Avenir-Heavy"
        bouquetLabel.fontSize = 26
        bouquetLabel.fontColor = UIColor(red: 0.6, green: 0.3, blue: 0.4, alpha: 1.0)
        bouquetLabel.position = CGPoint(
            x: bouquetRect.midX,
            y: bouquetRect.maxY + 30
        )
        bouquetLabel.zPosition = 2
        addChild(bouquetLabel)
        
        // Add decorative vase placeholder
        let vaseHeight: CGFloat = 80
        let vaseWidth: CGFloat = 100
        let vase = SKShapeNode(rect: CGRect(
            x: bouquetRect.midX - vaseWidth / 2,
            y: bouquetRect.minY - 20,
            width: vaseWidth,
            height: vaseHeight
        ))
        vase.fillColor = UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 0.6)
        vase.strokeColor = UIColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 1.0)
        vase.lineWidth = 2
        vase.zPosition = 0
        addChild(vase)
    }
    
    private func setupFlowers() {
        // Create placeholder flowers with different colors
        let flowerTypes = [
            ("Rose", UIColor(red: 1.0, green: 0.4, blue: 0.5, alpha: 1.0)),
            ("Tulip", UIColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 1.0)),
            ("Daisy", UIColor(red: 1.0, green: 0.95, blue: 0.5, alpha: 1.0)),
            ("Lily", UIColor(red: 0.95, green: 0.8, blue: 1.0, alpha: 1.0)),
            ("Sunflower", UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)),
        ]

        let flowerSize = CGSize(width: 60, height: 80)
        let startY = inventoryRect.maxY - 100
        let spacing: CGFloat = 100

        for (index, flowerData) in flowerTypes.enumerated() {
            let flower = FlowerNode(type: flowerData.0, color: flowerData.1, size: flowerSize)

            // Position in inventory (but start off-screen)
            let yPos = startY - (CGFloat(index) * spacing)
            let finalPosition = CGPoint(x: inventoryRect.midX, y: yPos)
            flower.position = CGPoint(x: -inventoryRect.width, y: yPos)  // Start off-screen
            flower.originalPosition = finalPosition
            flower.zPosition = 5
            flower.alpha = 0.0  // Start invisible

            // Add a simple shape to represent the flower
            addFlowerShape(to: flower)

            // Add label
            let label = SKLabelNode(text: flowerData.0)
            label.fontName = "Avenir-Medium"
            label.fontSize = 14
            label.fontColor = .darkGray
            label.position = CGPoint(x: 0, y: -flowerSize.height / 2 - 15)
            label.zPosition = 1
            flower.addChild(label)

            addChild(flower)
            flowers.append(flower)
        }
    }
    
    private func addFlowerShape(to flower: FlowerNode) {
        // Create a simple flower representation
        let petalCount = 5
        let petalRadius: CGFloat = 20
        let centerRadius: CGFloat = 12
        
        // Petals
        for i in 0..<petalCount {
            let angle = (CGFloat(i) * 2 * .pi) / CGFloat(petalCount) - .pi / 2
            let petal = SKShapeNode(circleOfRadius: petalRadius)
            petal.fillColor = flower.color
            petal.strokeColor = flower.color.withAlphaComponent(0.8)
            petal.lineWidth = 2
            petal.position = CGPoint(
                x: cos(angle) * centerRadius,
                y: sin(angle) * centerRadius + 10
            )
            petal.zPosition = -1
            flower.addChild(petal)
        }
        
        // Center
        let center = SKShapeNode(circleOfRadius: centerRadius)
        center.fillColor = UIColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0)
        center.strokeColor = UIColor.orange
        center.lineWidth = 2
        center.position = CGPoint(x: 0, y: 10)
        flower.addChild(center)
        
        // Stem
        let stemPath = UIBezierPath()
        stemPath.move(to: CGPoint(x: 0, y: 0))
        stemPath.addLine(to: CGPoint(x: 0, y: -30))
        let stem = SKShapeNode(path: stemPath.cgPath)
        stem.strokeColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        stem.lineWidth = 4
        flower.addChild(stem)
    }
    
    private func addInstructions() {
        let instructions = SKLabelNode(text: "Drag flowers from inventory to create your bouquet")
        instructions.fontName = "Avenir-Book"
        instructions.fontSize = 18
        instructions.fontColor = UIColor.darkGray.withAlphaComponent(0.7)
        instructions.position = CGPoint(x: size.width / 2, y: 40)
        instructions.zPosition = 10
        addChild(instructions)
    }

    // MARK: - Animations
    private func animateInventoryIn() {
        // Animate inventory area sliding in with ease-in effect
        let slideIn = SKAction.moveTo(x: inventoryOnscreenPosition.x, duration: 0.8)
        slideIn.timingMode = .easeIn
        let fadeIn = SKAction.fadeIn(withDuration: 0.6)
        let inventoryAnimation = SKAction.group([slideIn, fadeIn])

        // Add a slight delay before starting
        let delayAction = SKAction.wait(forDuration: 0.2)
        let sequence = SKAction.sequence([delayAction, inventoryAnimation])

        inventoryArea.run(sequence)

        // Animate flowers sliding in with staggered timing
        for (index, flower) in flowers.enumerated() {
            let flowerDelay = 0.3 + (Double(index) * 0.1)  // Stagger each flower
            let flowerSlideIn = SKAction.moveTo(x: flower.originalPosition.x, duration: 0.7)
            flowerSlideIn.timingMode = .easeIn
            let flowerFadeIn = SKAction.fadeIn(withDuration: 0.5)

            let flowerAnimation = SKAction.group([flowerSlideIn, flowerFadeIn])
            let flowerSequence = SKAction.sequence([
                SKAction.wait(forDuration: flowerDelay),
                flowerAnimation
            ])

            flower.run(flowerSequence) {
                // Update flower position once animation completes
                flower.position = flower.originalPosition
            }
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if we touched a flower
        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            if let flower = node as? FlowerNode {
                selectedFlower = flower
                flower.zPosition = 100 // Bring to front
                
                // Scale up slightly for feedback
                flower.run(SKAction.scale(to: 1.1, duration: 0.1))
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let flower = selectedFlower else { return }
        
        let location = touch.location(in: self)
        flower.position = location
        
        // Visual feedback when over bouquet area
        if bouquetRect.contains(location) {
            bouquetArea.run(SKAction.scale(to: 1.05, duration: 0.1))
            bouquetArea.fillColor = UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 0.9)
        } else {
            bouquetArea.run(SKAction.scale(to: 1.0, duration: 0.1))
            bouquetArea.fillColor = UIColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 0.9)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let flower = selectedFlower else { return }
        
        let location = touch.location(in: self)
        
        // Reset bouquet area
        bouquetArea.run(SKAction.scale(to: 1.0, duration: 0.2))
        bouquetArea.fillColor = UIColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 0.9)
        
        // Check if dropped in bouquet area
        if bouquetRect.contains(location) {
            // Successfully placed in bouquet
            flower.isInInventory = false
            flower.run(SKAction.scale(to: 1.0, duration: 0.2))
            
            // Haptic feedback for success
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Gentle bounce animation
            let bounce = SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.1),
                SKAction.scale(to: 0.95, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            flower.run(bounce)
            
            // Update original position to current position
            flower.originalPosition = location
            
        } else if inventoryRect.contains(location) {
            // Dropped back in inventory
            flower.isInInventory = true
            returnFlowerToInventory(flower)
        } else {
            // Dropped outside both areas - return to original position
            returnFlowerToOriginalPosition(flower)
        }
        
        selectedFlower = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let flower = selectedFlower {
            returnFlowerToOriginalPosition(flower)
            selectedFlower = nil
        }
    }
    
    // MARK: - Helper Methods
    private func returnFlowerToOriginalPosition(_ flower: FlowerNode) {
        let moveBack = SKAction.move(to: flower.originalPosition, duration: 0.3)
        moveBack.timingMode = .easeOut
        let scaleBack = SKAction.scale(to: 1.0, duration: 0.3)
        flower.run(SKAction.group([moveBack, scaleBack]))
        flower.zPosition = 5
    }
    
    private func returnFlowerToInventory(_ flower: FlowerNode) {
        // Find original inventory position
        if let index = flowers.firstIndex(of: flower) {
            let startY = inventoryRect.maxY - 100
            let spacing: CGFloat = 100
            let yPos = startY - (CGFloat(index) * spacing)
            let inventoryPos = CGPoint(x: inventoryRect.midX, y: yPos)
            
            flower.originalPosition = inventoryPos
            
            let moveBack = SKAction.move(to: inventoryPos, duration: 0.3)
            moveBack.timingMode = .easeOut
            let scaleBack = SKAction.scale(to: 1.0, duration: 0.3)
            flower.run(SKAction.group([moveBack, scaleBack]))
            flower.zPosition = 5
        }
    }
    
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        // Future: Add gentle floating animation to flowers
    }
}
