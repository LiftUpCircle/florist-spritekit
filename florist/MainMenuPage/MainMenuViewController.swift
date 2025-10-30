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
    @Published var navigateToBouquet = false
    @Published var navigateToMemories = false
    @Published var navigateToOptions = false

    func handleMenuSelection(_ item: MainMenuModel.MenuItem) {
        switch item {
        case .start:
            navigateToBouquet = true
        case .memories:
            navigateToMemories = true
        case .options:
            navigateToOptions = true
        }
    }

    func resetNavigation() {
        navigateToBouquet = false
        navigateToMemories = false
        navigateToOptions = false
    }
}
