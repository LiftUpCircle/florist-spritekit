//
//  MainMenuModel.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import Foundation

struct MainMenuModel {
    enum MenuItem: String, CaseIterable, Hashable {
        case start = "Start"
        case memories = "Memories"
        case options = "Options"
    }

    var menuItems: [MenuItem] = MenuItem.allCases
}
