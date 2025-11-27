import SpriteKit

class MagnifierLens: SKNode {

    private let lensSize: CGFloat
    private let zoomScale: CGFloat
    private var lensBackground: SKShapeNode!
    private var lensBorder: SKShapeNode!
    private var contentContainer: SKCropNode!
    private var snapshotSprite: SKSpriteNode?

    private weak var targetScene: SKScene?

    init(size: CGFloat = 120, zoomScale: CGFloat = 2.0) {
        self.lensSize = size
        self.zoomScale = zoomScale
        super.init()

        setupLens()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLens() {
        let radius = lensSize / 2

        lensBackground = SKShapeNode(circleOfRadius: radius)
        lensBackground.fillColor = UIColor.white.withAlphaComponent(0.95)
        lensBackground.strokeColor = .clear
        lensBackground.zPosition = 0
        addChild(lensBackground)

        contentContainer = SKCropNode()
        contentContainer.zPosition = 1

        let maskNode = SKShapeNode(circleOfRadius: radius - 4)
        maskNode.fillColor = .white
        contentContainer.maskNode = maskNode
        addChild(contentContainer)

        lensBorder = SKShapeNode(circleOfRadius: radius)
        lensBorder.fillColor = .clear
        lensBorder.strokeColor = UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)
        lensBorder.lineWidth = 4
        lensBorder.zPosition = 2
        addChild(lensBorder)

        let innerBorder = SKShapeNode(circleOfRadius: radius - 2)
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = UIColor.white.withAlphaComponent(0.5)
        innerBorder.lineWidth = 2
        innerBorder.zPosition = 3
        addChild(innerBorder)

        self.zPosition = 500
        self.isHidden = true
    }

    func setTargetScene(_ scene: SKScene) {
        self.targetScene = scene
    }

    func show(at position: CGPoint, focusPoint: CGPoint, in scene: SKScene) {
        guard let view = scene.view else { return }

        self.position = position
        self.isHidden = false

        snapshotSprite?.removeFromParent()

        let texture = view.texture(from: scene)

        if let texture = texture {
            let sprite = SKSpriteNode(texture: texture)

            sprite.setScale(zoomScale)

            let sceneCenter = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
            let offsetX = (sceneCenter.x - focusPoint.x) * zoomScale
            let offsetY = (sceneCenter.y - focusPoint.y) * zoomScale
            sprite.position = CGPoint(x: offsetX, y: offsetY)

            sprite.zPosition = 0

            contentContainer.addChild(sprite)
            snapshotSprite = sprite
        }

        self.setScale(0.5)
        self.alpha = 0
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.15)
        let fadeIn = SKAction.fadeIn(withDuration: 0.15)
        scaleUp.timingMode = .easeOut
        self.run(SKAction.group([scaleUp, fadeIn]))
    }

    func update(position: CGPoint, focusPoint: CGPoint, in scene: SKScene) {
        guard !self.isHidden, let view = scene.view else { return }

        self.position = position

        snapshotSprite?.removeFromParent()

        let texture = view.texture(from: scene)

        if let texture = texture {
            let sprite = SKSpriteNode(texture: texture)
            sprite.setScale(zoomScale)

            let sceneCenter = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
            let offsetX = (sceneCenter.x - focusPoint.x) * zoomScale
            let offsetY = (sceneCenter.y - focusPoint.y) * zoomScale
            sprite.position = CGPoint(x: offsetX, y: offsetY)

            sprite.zPosition = 0

            contentContainer.addChild(sprite)
            snapshotSprite = sprite
        }
    }

    func hide() {
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let hideAction = SKAction.run { [weak self] in
            self?.isHidden = true
            self?.snapshotSprite?.removeFromParent()
            self?.snapshotSprite = nil
        }
        self.run(SKAction.sequence([
            SKAction.group([scaleDown, fadeOut]),
            hideAction
        ]))
    }
}
