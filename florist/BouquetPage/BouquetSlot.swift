//
//  BouquetSlot.swift
//  florist
//
//  Created by reynaldo on 03/11/25.
//

import SpriteKit

// MARK: - Bouquet Slot Node
class BouquetSlot: SKNode {
    let slotIndex: Int
    let slotSize: CGSize
    var isOccupied: Bool = false
    var placedFlower: FlowerNode?
    
    private var slotBackground: SKShapeNode!
    private var slotBorder: SKShapeNode!
    
    init(index: Int, size: CGSize) {
        self.slotIndex = index
        self.slotSize = size
        super.init()
        
        setupSlot()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSlot() {
        // Slot background
        slotBackground = SKShapeNode(rectOf: slotSize, cornerRadius: 10)
        slotBackground.fillColor = UIColor.white.withAlphaComponent(0.3)
        slotBackground.strokeColor = .clear
        slotBackground.zPosition = 0
        addChild(slotBackground)
        
        // Slot border (dashed)
        slotBorder = SKShapeNode(rectOf: slotSize, cornerRadius: 10)
        slotBorder.fillColor = .clear
        slotBorder.strokeColor = UIColor.gray.withAlphaComponent(0.5)
        slotBorder.lineWidth = 2
        
        // Create dashed line effect
        let pattern: [CGFloat] = [5, 5]
        if let path = slotBorder.path {
            let dashedPath = path.copy(dashingWithPhase: 0, lengths: pattern)
            slotBorder.path = dashedPath
        }
        
        slotBorder.zPosition = 1
        addChild(slotBorder)
        
        // Add a subtle "+" icon to indicate empty slot
        let plusLabel = SKLabelNode(text: "+")
        plusLabel.fontName = "Avenir-Light"
        plusLabel.fontSize = 40
        plusLabel.fontColor = UIColor.gray.withAlphaComponent(0.3)
        plusLabel.verticalAlignmentMode = .center
        plusLabel.zPosition = 2
        plusLabel.name = "plusIcon"
        addChild(plusLabel)
    }
    
    func placeFlower(_ flower: FlowerNode) {
        guard !isOccupied else { return }
        
        isOccupied = true
        placedFlower = flower
        
        // Hide the plus icon
        childNode(withName: "plusIcon")?.alpha = 0
        
        // Update slot appearance
        slotBackground.fillColor = UIColor.white.withAlphaComponent(0.6)
        slotBorder.strokeColor = UIColor.green.withAlphaComponent(0.7)
        
        // Position flower in center of slot
        flower.position = .zero
        flower.zPosition = 5
        addChild(flower)
    }
    
    func removeFlower() -> FlowerNode? {
        guard isOccupied, let flower = placedFlower else { return nil }
        
        isOccupied = false
        placedFlower = nil
        
        // Show the plus icon again
        childNode(withName: "plusIcon")?.alpha = 1.0
        
        // Reset slot appearance
        slotBackground.fillColor = UIColor.white.withAlphaComponent(0.3)
        slotBorder.strokeColor = UIColor.gray.withAlphaComponent(0.5)
        
        flower.removeFromParent()
        return flower
    }
    
    func highlightSlot() {
        slotBorder.strokeColor = UIColor.blue.withAlphaComponent(0.8)
        slotBackground.fillColor = UIColor.blue.withAlphaComponent(0.2)
        
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.1)
        run(scaleUp)
    }
    
    func unhighlightSlot() {
        if isOccupied {
            slotBorder.strokeColor = UIColor.green.withAlphaComponent(0.7)
            slotBackground.fillColor = UIColor.white.withAlphaComponent(0.6)
        } else {
            slotBorder.strokeColor = UIColor.gray.withAlphaComponent(0.5)
            slotBackground.fillColor = UIColor.white.withAlphaComponent(0.3)
        }
        
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleDown)
    }
}
