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

    // Drag tutorial properties
    private var tutorialHandNode: SKSpriteNode?
    private var isTutorialShowing: Bool = false
    private let tutorialKey = "BouquetDragTutorialCompleted"

    // Book tooltip properties
    private var tooltipContainer: SKNode?
    private var tooltipBackground: SKShapeNode?
    private var tooltipLabel: SKLabelNode?
    private var tooltipArrow: SKShapeNode?
    private var isTooltipShowing: Bool = false
    private let bookOpenedKey = "FlowerBookOpened"
    private let bookTooltipShownKey = "BookTooltipShown"

    // State tracking
    var hasDraggedFlowerToBouquet: Bool = false {
        didSet {
            if hasDraggedFlowerToBouquet {
                UserDefaults.standard.set(true, forKey: tutorialKey)
            }
        }
    }

    var hasOpenedFlowerBook: Bool = false {
        didSet {
            if hasOpenedFlowerBook {
                UserDefaults.standard.set(true, forKey: bookOpenedKey)
                hideBookTooltip()
            }
        }
    }

    var hasPlacedFirstFlower: Bool = false
    private var hasShownBookTooltip: Bool = false

    // MARK: - Initialization
    init(scene: SKScene) {
        self.scene = scene
        // Load tutorial completion state from UserDefaults
        self.hasDraggedFlowerToBouquet = UserDefaults.standard.bool(forKey: tutorialKey)
        self.hasOpenedFlowerBook = UserDefaults.standard.bool(forKey: bookOpenedKey)
        self.hasShownBookTooltip = UserDefaults.standard.bool(forKey: bookTooltipShownKey)
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

    // MARK: - Book Tooltip Methods
    func onFlowerPlaced(bookButton: SKSpriteNode) {
        // Mark that user has placed their first flower
        hasPlacedFirstFlower = true

        // Show book tooltip if conditions are met
        if shouldShowBookTooltip() {
            showBookTooltip(bookButton: bookButton)
        }
    }

    func onBookButtonPressed() {
        hasOpenedFlowerBook = true
        hideBookTooltip()
    }

    func showTemporaryBookTooltip(bookButton: SKSpriteNode, message: String = "View Flower Guide", duration: TimeInterval = 3.0) {
        // Hide any existing tooltip
        hideBookTooltip()

        isTooltipShowing = true
        createBookTooltip(near: bookButton, message: message)

        // Auto-hide after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.hideBookTooltip()
        }
    }

    func hideBookTooltip() {
        guard isTooltipShowing else { return }

        tooltipContainer?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ])) { [weak self] in
            self?.tooltipContainer = nil
            self?.tooltipBackground = nil
            self?.tooltipLabel = nil
            self?.tooltipArrow = nil
            self?.isTooltipShowing = false
        }
    }

    private func shouldShowBookTooltip() -> Bool {
        // Show tooltip only if:
        // 1. User has placed their first flower
        // 2. User hasn't opened the book yet
        // 3. We haven't shown the tooltip in this session yet
        return hasPlacedFirstFlower && !hasOpenedFlowerBook && !hasShownBookTooltip
    }

    private func showBookTooltip(bookButton: SKSpriteNode) {
        guard !isTooltipShowing else { return }

        isTooltipShowing = true
        hasShownBookTooltip = true
        UserDefaults.standard.set(true, forKey: bookTooltipShownKey)

        createBookTooltip(near: bookButton)

        // Auto-hide after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.hideBookTooltip()
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

    private func createBookTooltip(near button: SKSpriteNode, message: String = "Check Flower Guide") {
        guard let scene = scene else { return }

        // Create container node
        tooltipContainer = SKNode()
        tooltipContainer?.zPosition = 250 // Above most elements but below modals

        // Calculate position (to the left of the button)
        let tooltipX = button.position.x - button.size.width - 40
        let tooltipY = button.position.y
        tooltipContainer?.position = CGPoint(x: tooltipX, y: tooltipY)

        // Create background
        let backgroundWidth: CGFloat = 140
        let backgroundHeight: CGFloat = 36

        tooltipBackground = SKShapeNode(rectOf: CGSize(width: backgroundWidth, height: backgroundHeight), cornerRadius: 8)
        tooltipBackground?.fillColor = UIColor(white: 0.1, alpha: 0.9)
        tooltipBackground?.strokeColor = UIColor(white: 0.3, alpha: 0.8)
        tooltipBackground?.lineWidth = 1

        // Create label
        tooltipLabel = SKLabelNode(text: message)
        tooltipLabel?.fontName = "Gaegu-Bold"
        tooltipLabel?.fontSize = 16
        tooltipLabel?.fontColor = .white
        tooltipLabel?.verticalAlignmentMode = .center
        tooltipLabel?.horizontalAlignmentMode = .center
        tooltipLabel?.zPosition = 1

        // Create arrow pointing to the button (triangle on the right side)
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 0, y: 0))
        arrowPath.addLine(to: CGPoint(x: -10, y: -8))
        arrowPath.addLine(to: CGPoint(x: -10, y: 8))
        arrowPath.close()

        tooltipArrow = SKShapeNode(path: arrowPath.cgPath)
        tooltipArrow?.fillColor = UIColor(white: 0.1, alpha: 0.9)
        tooltipArrow?.strokeColor = UIColor(white: 0.3, alpha: 0.8)
        tooltipArrow?.lineWidth = 1
        tooltipArrow?.position = CGPoint(x: backgroundWidth / 2, y: 0)
        tooltipArrow?.zPosition = 0

        // Add components to container
        if let container = tooltipContainer,
           let background = tooltipBackground,
           let label = tooltipLabel,
           let arrow = tooltipArrow {

            container.addChild(background)
            container.addChild(label)
            container.addChild(arrow)

            // Set initial alpha for fade-in animation
            container.alpha = 0

            // Add to scene
            scene.addChild(container)

            // Animate appearance
            container.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.group([
                    SKAction.sequence([
                        SKAction.scale(to: 1.05, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ]),
                    createPulseAnimation()
                ])
            ]))
        }
    }

    private func createPulseAnimation() -> SKAction {
        // Create a subtle pulse animation for the tooltip
        let scaleUp = SKAction.scale(to: 1.02, duration: 1.0)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SKAction.scale(to: 0.98, duration: 1.0)
        scaleDown.timingMode = .easeInEaseOut

        let pulse = SKAction.sequence([scaleUp, scaleDown])
        return SKAction.repeatForever(pulse)
    }
}
