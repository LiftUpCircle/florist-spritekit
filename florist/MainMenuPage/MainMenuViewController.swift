//
//  MainMenuViewController.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import SwiftUI
import Combine

class MainMenuViewController: ObservableObject {
    @Published var model = MainMenuModel()
    @Published var navigationPath = NavigationPath()

    func handleMenuSelection(_ item: MainMenuModel.MenuItem) {
        navigationPath.append(item)
    }

    func resetNavigation() {
        navigationPath = NavigationPath()
    }
}
