//
//  FlowerBookController.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 06/11/25.
//

import Foundation
import SwiftUI
import Combine

class FlowerBookController: ObservableObject {
    @Published var viewModel: FlowerBookViewModel
    
    init() {
        self.viewModel = FlowerBookViewModel()
    }
    
    func handleDismiss() {
        // Any cleanup or state management before dismissing
    }
}

