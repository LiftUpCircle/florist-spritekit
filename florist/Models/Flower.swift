//
//  Flower.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import Foundation

struct Flower: Identifiable, Codable {
    let flowerId: Int
    let flowerName: String
    let flowerImg: String

    var id: Int { flowerId }
}
