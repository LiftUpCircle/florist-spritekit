//
//  BouquetTutorialManager.swift
//  florist
//
//  Created by Assistant on 18/11/25.
//

import SpriteKit

class BouquetTutorialManager {
    // MARK: - Properties
    private weak var scene: SKScene?
    private var tutorialHandNode: SKSpriteNode?
    private var isTutorialShowing: Bool = false
    private let tutorialKey = "BouquetDragTutorialCompleted"

    var hasDraggedFlowerToBouquet: Bool = false {
        didSet {
            if hasDraggedFlowerToBouquet {
                UserDefaults.standard.set(true, forKey: tutorialKey)
            }
        }
    }

    // MARK: - Initialization
    init(scene: SKScene) {
        self.scene = scene
        // Load tutorial completion state from UserDefaults
        self.hasDraggedFlowerToBouquet = UserDefaults.standard.bool(forKey: tutorialKey)
    }

    // MARK: - Public Methods
    func showTutorialIfNeeded(inventoryFlowers: [SKNode], inventoryScrollNode: SKNode, bouquetRect: CGRect) {
        // Only show tutorial if user hasn't dragged a flower to the bouquet yet
        guard !hasDraggedFlowerToBouquet && !isTutorialShowing else { return }

        // Check if we have flowers in inventory
        guard !inventoryFlowers.isEmpty else { return }

        isTutorialShowing = true
        createTutorialAnimation(
            firstFlower: inventoryFlowers.first!,
            inventoryScrollNode: inventoryScrollNode,
            bouquetRect: bouquetRect
        )
    }

    func hideTutorial() {
        // Remove tutorial if it's showing
        if isTutorialShowing {
            tutorialHandNode?.removeAllActions()
            tutorialHandNode?.removeFromParent()
            tutorialHandNode = nil
            isTutorialShowing = false
        }
    }

    func markTutorialCompleted() {
        if !hasDraggedFlowerToBouquet {
            hasDraggedFlowerToBouquet = true
            hideTutorial()
        }
    }

    // MARK: - Private Methods
    private func createTutorialAnimation(firstFlower: SKNode, inventoryScrollNode: SKNode, bouquetRect: CGRect) {
        guard let scene = scene else { return }

        // Create hand icon node
        if let handTexture = SKTexture(imageNamed: "handIconTutorial") as SKTexture? {
            tutorialHandNode = SKSpriteNode(texture: handTexture)
            tutorialHandNode?.size = CGSize(width: 80, height: 80)
            tutorialHandNode?.zPosition = 300 // Above everything else
            tutorialHandNode?.alpha = 0.0

            // Convert flower position to world coordinates
            let startPos = inventoryScrollNode.convert(firstFlower.position, to: scene)

            // Calculate end position (center of bouquet area)
            let endPos = CGPoint(x: bouquetRect.midX, y: bouquetRect.midY)

            // Add the hand to the scene
            if let handNode = tutorialHandNode {
                handNode.position = startPos
                scene.addChild(handNode)

                // Create the tutorial animation sequence
                let fadeIn = SKAction.fadeIn(withDuration: 0.3)

                // Create dragging animation
                let moveToEnd = SKAction.move(to: endPos, duration: 2.0)
                moveToEnd.timingMode = .easeInEaseOut

                // Add some scaling for emphasis
                let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
                let scaleDown = SKAction.scale(to: 0.9, duration: 0.5)
                let scaleSequence = SKAction.sequence([scaleUp, scaleDown])

                // Fade out at the end
                let fadeOut = SKAction.fadeOut(withDuration: 0.3)

                // Wait and return to start
                let wait = SKAction.wait(forDuration: 0.5)
                let moveBack = SKAction.move(to: startPos, duration: 0.0)

                // Complete animation sequence
                let animationSequence = SKAction.sequence([
                    fadeIn,
                    SKAction.group([moveToEnd, scaleSequence]),
                    fadeOut,
                    wait,
                    moveBack
                ])

                // Repeat the animation 3 times
                let repeatAction = SKAction.repeat(animationSequence, count: 3)

                // Run the animation and clean up after
                handNode.run(repeatAction) { [weak self] in
                    self?.tutorialHandNode?.removeFromParent()
                    self?.tutorialHandNode = nil
                    self?.isTutorialShowing = false
                }
            }
        }
    }
}