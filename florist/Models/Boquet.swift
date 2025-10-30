//
//  Boquet.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import Foundation

struct Boquet: Identifiable, Codable {
    let boquetId: UUID
    var flowers: [Flower]

    var id: UUID { boquetId }

    init(boquetId: UUID = UUID(), flowers: [Flower] = []) {
        self.boquetId = boquetId
        self.flowers = flowers
    }
}
