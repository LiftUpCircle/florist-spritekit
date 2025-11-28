//
//  BookContentView.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 06/11/25.
//

import SwiftUI
import AVFoundation

struct BookContentView: View {
    let flower: Flower
    let onPrevious: () -> Void
    let onNext: () -> Void
    let canGoPrevious: Bool
    let canGoNext: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    
                    // LEFT SIDE - Flower Image
                    VStack(spacing: 18) {
                        Text("Flower")
                            .font(.title2Gaegu)
                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.2))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .offset(y: -10)
                        
                        if let imageName = getFlowerImageName(for: flower.flowerName) {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.45,
                                       height: geometry.size.width * 0.45)
                                .offset(x: -18, y: -30)
                        }
                    }
                    .frame(width: geometry.size.width * 0.5, alignment: .center)
                    
                    
                    // RIGHT SIDE - Flower Descriptions
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(Array(getHighlightedFlowerDescriptions(for: flower.flowerName).enumerated()), id: \.offset) { index, attributedDescription in
                            Text(attributedDescription)
                                .font(.footnoteGaegu)
                                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.2))
                                .lineSpacing(3)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.bookDesc)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(red: 0.8, green: 0.7, blue: 0.6), lineWidth: 2)
                                        )
                                )
                                .rotationEffect(.degrees(Double.random(in: -3...3)))
                        }
                    }
                    .frame(width: geometry.size.width * 0.4, alignment: .leading)
                    .offset(x: 20, y: -10)
                    .id(flower.id)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                
                HStack {
                    // Previous Button
                    if canGoPrevious {
                        Button(action: {
                            onPrevious()
                            playFlippingSound()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 44, height: 44)
                                )
                        }
                        .padding(.leading, -20)
                    }
                    
                    Spacer()
                    
                    // Next Button
                    if canGoNext {
                        Button(action: {
                            onNext()
                            playFlippingSound()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 44, height: 44)
                                )
                        }
                        .padding(.trailing, -5)
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .onAppear {
                // Preload flipping sound
                SettingsManager.shared.preloadSound(named: "flippingbook")
            }
        }
    }
    
    // helper function to play flipping sound
    private func playFlippingSound() {
        print("🎵 Button pressed - attempting to play flipping sound")
        SettingsManager.shared.playPageFlip()
    }
    
    private func getFlowerImageName(for flowerName: String) -> String? {
        switch flowerName {
        case "Rose": return "RoseBook"
        case "Jasmine": return "JasmineBook"
        case "Lavender": return "LavenderBook"
        case "Carnation": return "CarnationBook"
        case "Lily": return "LilyBook"
        case "Tulip": return "TulipBook"
        default: return nil
        }
    }
    
    private func getFlowerDescriptions(for flowerName: String) -> [String] {
        switch flowerName {
        case "Rose":
            return [
                "Symbolizes deep bonds and devoted love.",
                "Layers of petals represent layered affection.",
                "For proposals, anniversaries, and true partnership."
            ]
        case "Jasmine":
            return [
                "Represents purity, innocence, and fresh starts.",
                "Sacred in Indonesia for its sweet, sincere fragrance.",
                "Given for new beginnings or expressing pure intentions."
            ]
        case "Lavender":
            return [
                "Symbolizes calm, quiet, and serenity.",
                "Known for its soothing, stress-reducing aroma.",
                "Given to wish peace or simply say \"take a rest.\""
            ]
        case "Carnation":
            return [
                "The flower of joy, cheerfulness, and affection.",
                "A sturdy, long-lasting bloom for simple happiness.",
                "For celebration, cheering someone up, or acts of kindness."
            ]
        case "Lily":
            return [
                "Represents hope, new beginnings, and quiet dignity.",
                "Elegant shape evokes grace and optimism.",
                "For fresh starts or to inspire hope in someone."
            ]
        case "Tulip":
            return [
                "Represents elegance, grace, and refined beauty.",
                "Its delicate cup holds deep, personal feelings.",
                "The classic flower for expressing sincere emotions."
            ]
        default:
            return ["A beautiful flower with special meaning."]
        }
    }
    
    private func getKeywords(for flowerName: String) -> [String] {
        switch flowerName {
        case "Rose":
            return ["love", "deep bonds", "devoted love", "layered affection", "proposals", "anniversaries", "true partnership"]
        case "Jasmine":
            return ["purity", "innocence", "fresh starts", "sacred", "sweet", "sincere fragrance", "new beginnings", "pure intentions"]
        case "Lavender":
            return ["serenity", "calm", "quiet", "soothing", "stress-reducing", "peace", "take a rest"]
        case "Carnation":
            return ["joy", "cheerfulness", "affection", "sturdy", "long-lasting", "simple happiness", "celebration", "acts of kindness"]
        case "Lily":
            return ["hope", "new beginnings", "quiet dignity", "elegant", "grace", "optimism", "fresh starts", "inspire hope"]
        case "Tulip":
            return ["elegance", "grace", "refined beauty", "delicate cup", "deep", "personal feelings", "sincere emotions"]
        default:
            return []
        }
    }
    
    private func getHighlightedFlowerDescriptions(for flowerName: String) -> [AttributedString] {
        let descriptions = getFlowerDescriptions(for: flowerName)
        let keywords = getKeywords(for: flowerName)
        
        return descriptions.map { description in
            var attributedString = AttributedString(description)
            
            // Highlight each keyword
            for keyword in keywords {
                if let range = attributedString.range(of: keyword, options: .caseInsensitive) {
                    attributedString[range].foregroundColor = Color(.textPlayButton)
                    attributedString[range].font = .calloutGaegu.bold()
                }
            }
            
            return attributedString
        }
    }
}

