//
//  Typography.swift
//  florist
//
//  Created by Al Amin Dwiesta on 11/11/25.
//

import SwiftUI

// MARK: - Typography Design System

extension Font {

    // MARK: - Gaegu Font Family

    /// Large Title: Bold / 37px
    static let largeTitleGaegu = Font.custom("Gaegu-Bold", size: 37)

    /// Title 1: Bold / 31px
    static let title1Gaegu = Font.custom("Gaegu-Bold", size: 31)

    /// Title 2: Bold / 29px
    static let title2Gaegu = Font.custom("Gaegu-Bold", size: 29)

    /// Title 3: Bold / 21px
    static let title3Gaegu = Font.custom("Gaegu-Bold", size: 21)

    /// Headline: Bold / 19px
    static let headlineGaegu = Font.custom("Gaegu-Bold", size: 19)

    /// Body: Regular / 17px
    static let bodyGaegu = Font.custom("Gaegu-Regular", size: 17)

    /// Callout: Regular / 17px
    static let calloutGaegu = Font.custom("Gaegu-Regular", size: 17)

    /// Subhead: Regular / 15px
    static let subheadGaegu = Font.custom("Gaegu-Regular", size: 15)

    /// Footnote: Regular / 15px
    static let footnoteGaegu = Font.custom("Gaegu-Regular", size: 15)

    /// Caption 1: Regular / 13px
    static let caption1Gaegu = Font.custom("Gaegu-Regular", size: 13)

    /// Caption 2: Regular / 13px
    static let caption2Gaegu = Font.custom("Gaegu-Regular", size: 13)
}

// MARK: - UIKit Typography (for SpriteKit)

struct GaeguTypography {

    // MARK: - UIFont for SpriteKit/UIKit

    /// Large Title: Bold / 37pt
    static let largeTitle = UIFont(name: "Gaegu-Bold", size: 37) ?? UIFont.boldSystemFont(ofSize: 37)

    /// Title 1: Bold / 31pt
    static let title1 = UIFont(name: "Gaegu-Bold", size: 31) ?? UIFont.boldSystemFont(ofSize: 31)

    /// Title 2: Bold / 29pt
    static let title2 = UIFont(name: "Gaegu-Bold", size: 29) ?? UIFont.boldSystemFont(ofSize: 29)

    /// Title 3: Bold / 21pt
    static let title3 = UIFont(name: "Gaegu-Bold", size: 21) ?? UIFont.boldSystemFont(ofSize: 21)

    /// Headline: Bold / 19pt
    static let headline = UIFont(name: "Gaegu-Bold", size: 19) ?? UIFont.boldSystemFont(ofSize: 19)

    /// Body: Regular / 17pt
    static let body = UIFont(name: "Gaegu-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)

    /// Callout: Regular / 17pt
    static let callout = UIFont(name: "Gaegu-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)

    /// Subhead: Regular / 15pt
    static let subhead = UIFont(name: "Gaegu-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)

    /// Footnote: Regular / 15pt
    static let footnote = UIFont(name: "Gaegu-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)

    /// Caption 1: Regular / 13pt
    static let caption1 = UIFont(name: "Gaegu-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)

    /// Caption 2: Regular / 13pt
    static let caption2 = UIFont(name: "Gaegu-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)

    // MARK: - Font Name Strings (for SKLabelNode)

    /// Bold font name
    static let boldFontName = "Gaegu-Bold"

    /// Regular font name
    static let regularFontName = "Gaegu-Regular"

    /// Light font name
    static let lightFontName = "Gaegu-Light"
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
