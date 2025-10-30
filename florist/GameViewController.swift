//
//  GameViewController.swift
//  florist
//
//  Created by reynaldo on 28/10/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let view = self.view as! SKView? {
            if view.scene == nil {
                // Create the game scene with the correct size after layout
                let scene = GameScene(size: view.bounds.size)
                scene.scaleMode = .resizeFill

                // Present the scene
                view.presentScene(scene)

                view.ignoresSiblingOrder = true

                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Force landscape orientation
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
