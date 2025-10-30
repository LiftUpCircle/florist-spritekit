//
//  BouquetViewController.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import SwiftUI
import SpriteKit
import Combine

class BouquetViewController: ObservableObject {
    @Published var model = BouquetModel()

    func createGameScene() -> GameScene {
        let scene = GameScene()
        scene.scaleMode = model.sceneScaleMode
        return scene
    }

    func updateSceneSize(_ size: CGSize) {
        model.updateSceneSize(size)
    }
}
