//
//  BouquetModel.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import Foundation
import SpriteKit

struct BouquetModel {
    var sceneSize: CGSize = .zero
    var sceneScaleMode: SKSceneScaleMode = .resizeFill

    mutating func updateSceneSize(_ size: CGSize) {
        self.sceneSize = size
    }
}
