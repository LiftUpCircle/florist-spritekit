//
//  TextSizeManager.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 26/11/25.
//

import Foundation
import Combine

enum TextSize: String, CaseIterable {
    case normal = "Normal"
    case large = "Large"
    case extraLarge = "Extra Large"

    var multiplier: CGFloat {
        switch self {
        case .normal:
            return 1.0
        case .large:
            return 1.2
        case .extraLarge:
            return 1.4
        }
    }
}

class TextSizeManager: ObservableObject {
    static let shared = TextSizeManager()

    private let textSizeKey = "textSize"

    @Published var currentTextSize: TextSize {
        didSet {
            UserDefaults.standard.set(currentTextSize.rawValue, forKey: textSizeKey)
        }
    }

    private init() {
        if let savedRawValue = UserDefaults.standard.string(forKey: textSizeKey),
           let textSize = TextSize(rawValue: savedRawValue) {
            self.currentTextSize = textSize
        } else {
            self.currentTextSize = .normal
        }
    }

    var textSizeMultiplier: CGFloat {
        return currentTextSize.multiplier
    }

    func getScaledFont(size: CGFloat) -> CGFloat {
        return size * textSizeMultiplier
    }
}
