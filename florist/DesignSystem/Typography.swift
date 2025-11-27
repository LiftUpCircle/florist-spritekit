//
//  Typography.swift
//  florist
//
//  Created by Al Amin Dwiesta on 11/11/25.
//

import SwiftUI

// MARK: - Typography Design System (with Apple Dynamic Type)

extension Font {

    // MARK: - Gaegu Font Family (with Dynamic Type Support)

    /// Large Title: Bold - scales with Dynamic Type
    static var largeTitleGaegu: Font {
        .custom("Gaegu-Bold", size: 37, relativeTo: .largeTitle)
    }

    /// Title 1: Bold - scales with Dynamic Type
    static var title1Gaegu: Font {
        .custom("Gaegu-Bold", size: 31, relativeTo: .title)
    }

    /// Title 2: Bold - scales with Dynamic Type
    static var title2Gaegu: Font {
        .custom("Gaegu-Bold", size: 29, relativeTo: .title2)
    }

    /// Title 3: Bold - scales with Dynamic Type
    static var title3Gaegu: Font {
        .custom("Gaegu-Bold", size: 21, relativeTo: .title3)
    }

    /// Headline: Bold - scales with Dynamic Type
    static var headlineGaegu: Font {
        .custom("Gaegu-Bold", size: 19, relativeTo: .headline)
    }

    /// Body: Regular - scales with Dynamic Type
    static var bodyGaegu: Font {
        .custom("Gaegu-Regular", size: 17, relativeTo: .body)
    }

    /// Callout: Regular - scales with Dynamic Type
    static var calloutGaegu: Font {
        .custom("Gaegu-Regular", size: 17, relativeTo: .callout)
    }

    /// Subhead: Regular - scales with Dynamic Type
    static var subheadGaegu: Font {
        .custom("Gaegu-Regular", size: 15, relativeTo: .subheadline)
    }

    /// Footnote: Regular - scales with Dynamic Type
    static var footnoteGaegu: Font {
        .custom("Gaegu-Regular", size: 15, relativeTo: .footnote)
    }

    /// Caption 1: Regular - scales with Dynamic Type
    static var caption1Gaegu: Font {
        .custom("Gaegu-Regular", size: 13, relativeTo: .caption)
    }

    /// Caption 2: Regular - scales with Dynamic Type
    static var caption2Gaegu: Font {
        .custom("Gaegu-Regular", size: 13, relativeTo: .caption2)
    }

    // MARK: - Helper function for dynamic sizing

    static func gaeguFont(size: CGFloat, weight: String = "Regular", relativeTo textStyle: Font.TextStyle = .body) -> Font {
        let fontName = weight == "Bold" ? "Gaegu-Bold" : "Gaegu-Regular"
        return .custom(fontName, size: size, relativeTo: textStyle)
    }
}

// MARK: - UIKit Typography (for SpriteKit)

struct GaeguTypography {

    // MARK: - UIFont for SpriteKit/UIKit (with Dynamic Type Support)

    /// Large Title: Bold
    static var largeTitle: UIFont {
        scaledFont(name: "Gaegu-Bold", size: 37, textStyle: .largeTitle)
    }

    /// Title 1: Bold
    static var title1: UIFont {
        scaledFont(name: "Gaegu-Bold", size: 31, textStyle: .title1)
    }

    /// Title 2: Bold
    static var title2: UIFont {
        scaledFont(name: "Gaegu-Bold", size: 29, textStyle: .title2)
    }

    /// Title 3: Bold
    static var title3: UIFont {
        scaledFont(name: "Gaegu-Bold", size: 21, textStyle: .title3)
    }

    /// Headline: Bold
    static var headline: UIFont {
        scaledFont(name: "Gaegu-Bold", size: 19, textStyle: .headline)
    }

    /// Body: Regular
    static var body: UIFont {
        scaledFont(name: "Gaegu-Regular", size: 17, textStyle: .body)
    }

    /// Callout: Regular
    static var callout: UIFont {
        scaledFont(name: "Gaegu-Regular", size: 17, textStyle: .callout)
    }

    /// Subhead: Regular
    static var subhead: UIFont {
        scaledFont(name: "Gaegu-Regular", size: 15, textStyle: .subheadline)
    }

    /// Footnote: Regular
    static var footnote: UIFont {
        scaledFont(name: "Gaegu-Regular", size: 15, textStyle: .footnote)
    }

    /// Caption 1: Regular
    static var caption1: UIFont {
        scaledFont(name: "Gaegu-Regular", size: 13, textStyle: .caption1)
    }

    /// Caption 2: Regular
    static var caption2: UIFont {
        scaledFont(name: "Gaegu-Regular", size: 13, textStyle: .caption2)
    }

    // MARK: - Font Name Strings (for SKLabelNode)

    static let boldFontName = "Gaegu-Bold"
    static let regularFontName = "Gaegu-Regular"
    static let lightFontName = "Gaegu-Light"

    // MARK: - Helper function for Dynamic Type scaling

    static func scaledFont(name: String, size: CGFloat, textStyle: UIFont.TextStyle) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: UIFont.systemFont(ofSize: size))
        }
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }

    static func font(size: CGFloat, weight: String = "Regular", textStyle: UIFont.TextStyle = .body) -> UIFont {
        let fontName = weight == "Bold" ? "Gaegu-Bold" : "Gaegu-Regular"
        return scaledFont(name: fontName, size: size, textStyle: textStyle)
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
