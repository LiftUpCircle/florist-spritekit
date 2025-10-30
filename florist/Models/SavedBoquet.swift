//
//  SavedBoquet.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import Foundation

struct SavedBoquet: Codable {
    let savedBoquet: Boquet
    let boquetImg: String

    init(savedBoquet: Boquet, boquetImg: String = "") {
        self.savedBoquet = savedBoquet
        self.boquetImg = boquetImg
    }
}
