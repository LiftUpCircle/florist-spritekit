//
//  BouquetView.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import SwiftUI
import SpriteKit

struct BouquetView: View {
    @StateObject private var controller = BouquetViewController()

    var body: some View {
        ZStack {
            SpriteView(scene: controller.createGameScene())
                .ignoresSafeArea()
        }
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .statusBar(hidden: true)
    }
}

#Preview {
    BouquetView()
}
