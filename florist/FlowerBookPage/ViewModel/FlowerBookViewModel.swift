//
//  FlowerBookViewModel.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 06/11/25.
//

import Foundation
import SwiftUI
import Combine

class FlowerBookViewModel: ObservableObject {
    @Published var currentFlowerIndex: Int = 0
    
    let flowers: [Flower]
    
    init() {
        self.flowers = FlowerDatabase.shared.availableFlowers
        validateIndex()
    }
    
    var currentFlower: Flower? {
        guard currentFlowerIndex >= 0 && currentFlowerIndex < flowers.count else {
            return nil
        }
        return flowers[currentFlowerIndex]
    }
    
    var canGoPrevious: Bool {
        return currentFlowerIndex > 0
    }
    
    var canGoNext: Bool {
        return currentFlowerIndex < flowers.count - 1
    }
    
    func selectFlower(at index: Int) {
        guard index >= 0 && index < flowers.count else { return }
        withAnimation {
            currentFlowerIndex = index
        }
    }
    
    func goToPrevious() {
        guard canGoPrevious else { return }
        withAnimation {
            currentFlowerIndex -= 1
        }
    }
    
    func goToNext() {
        guard canGoNext else { return }
        withAnimation {
            currentFlowerIndex += 1
        }
    }
    
    private func validateIndex() {
        if currentFlowerIndex >= flowers.count {
            currentFlowerIndex = 0
        }
    }
}

