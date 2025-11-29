//
//  Typography.swift
//  florist
//
//  Created by Al Amin Dwiesta on 11/11/25.
//

import SwiftUI

// MARK: - Typography Design System

extension Font {

    // MARK: - Gaegu Font Family (with Text Size Multiplier Support)

    /// Large Title: Bold / 37px
    static var largeTitleGaegu: Font {
        let size = 37 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Bold", size: size)
    }

    /// Title 1: Bold / 31px
    static var title1Gaegu: Font {
        let size = 31 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Bold", size: size)
    }

    /// Title 2: Bold / 29px
    static var title2Gaegu: Font {
        let size = 29 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Bold", size: size)
    }

    /// Title 3: Bold / 21px
    static var title3Gaegu: Font {
        let size = 21 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Bold", size: size)
    }

    /// Headline: Bold / 19px
    static var headlineGaegu: Font {
        let size = 19 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Bold", size: size)
    }

    /// Body: Regular / 17px
    static var bodyGaegu: Font {
        let size = 17 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Regular", size: size)
    }

    /// Callout: Regular / 17px
    static var calloutGaegu: Font {
        let size = 17 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Regular", size: size)
    }

    /// Subhead: Regular / 15px
    static var subheadGaegu: Font {
        let size = 15 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Regular", size: size)
    }

    /// Footnote: Regular / 15px
    static var footnoteGaegu: Font {
        let size = 15 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Regular", size: size)
    }

    /// Caption 1: Regular / 13px
    static var caption1Gaegu: Font {
        let size = 13 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Regular", size: size)
    }

    /// Caption 2: Regular / 13px
    static var caption2Gaegu: Font {
        let size = 13 * TextSizeManager.shared.textSizeMultiplier
        return Font.custom("Gaegu-Regular", size: size)
    }

    // MARK: - Helper function for dynamic sizing

    static func gaeguFont(size: CGFloat, weight: String = "Regular") -> Font {
        let scaledSize = size * TextSizeManager.shared.textSizeMultiplier
        let fontName = weight == "Bold" ? "Gaegu-Bold" : "Gaegu-Regular"
        return Font.custom(fontName, size: scaledSize)
    }
}

// MARK: - UIKit Typography (for SpriteKit)

struct GaeguTypography {

    // MARK: - UIFont for SpriteKit/UIKit (with Text Size Multiplier Support)

    /// Large Title: Bold / 37pt
    static var largeTitle: UIFont {
        let size = 37 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }

    /// Title 1: Bold / 31pt
    static var title1: UIFont {
        let size = 31 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }

    /// Title 2: Bold / 29pt
    static var title2: UIFont {
        let size = 29 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }

    /// Title 3: Bold / 21pt
    static var title3: UIFont {
        let size = 21 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }

    /// Headline: Bold / 19pt
    static var headline: UIFont {
        let size = 19 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }

    /// Body: Regular / 17pt
    static var body: UIFont {
        let size = 17 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    /// Callout: Regular / 17pt
    static var callout: UIFont {
        let size = 17 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    /// Subhead: Regular / 15pt
    static var subhead: UIFont {
        let size = 15 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    /// Footnote: Regular / 15pt
    static var footnote: UIFont {
        let size = 15 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    /// Caption 1: Regular / 13pt
    static var caption1: UIFont {
        let size = 13 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    /// Caption 2: Regular / 13pt
    static var caption2: UIFont {
        let size = 13 * TextSizeManager.shared.textSizeMultiplier
        return UIFont(name: "Gaegu-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    // MARK: - Font Name Strings (for SKLabelNode)

    /// Bold font name
    static let boldFontName = "Gaegu-Bold"

    /// Regular font name
    static let regularFontName = "Gaegu-Regular"

    /// Light font name
    static let lightFontName = "Gaegu-Light"

    // MARK: - Helper function for dynamic sizing

    static func font(size: CGFloat, weight: String = "Regular") -> UIFont {
        let scaledSize = size * TextSizeManager.shared.textSizeMultiplier
        let fontName = weight == "Bold" ? "Gaegu-Bold" : "Gaegu-Regular"
        return UIFont(name: fontName, size: scaledSize) ?? UIFont.systemFont(ofSize: scaledSize)
    }
}

// MARK: - Font Size Reference

struct FontSize {
    static let largeTitle: CGFloat = 37
    static let title1: CGFloat = 31
    static let title2: CGFloat = 29
    static let title3: CGFloat = 21
    static let headline: CGFloat = 19
    static let body: CGFloat = 17
    static let callout: CGFloat = 17
    static let subhead: CGFloat = 15
    static let footnote: CGFloat = 15
    static let caption1: CGFloat = 13
    static let caption2: CGFloat = 13
}
