//
//  BookContentView.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 06/11/25.
//

import SwiftUI

struct BookContentView: View {
    let flower: Flower
    let onPrevious: () -> Void
    let onNext: () -> Void
    let canGoPrevious: Bool
    let canGoNext: Bool
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                
                ZStack(alignment: .topLeading) {
                    ZStack(alignment: .topLeading) {
                        VStack(alignment: .leading, spacing: 20) {
                            if let imageName = getFlowerImageName(for: flower.flowerName) {
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.25,
                                           height: geometry.size.width * 0.25)
                            }
                            
                            Text(flower.flowerName)
                                .font(.custom("Georgia", size: 30))
                                .foregroundColor(Color(red: 0.4, green: 0.25, blue: 0.2))
                                .fontWeight(.bold)
                                .italic()
                            
                            
                            if canGoPrevious {
                                Button(action: onPrevious) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))
                                }
                                .padding(.top, 10)
                            }
                        }
                        .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.5, alignment: .topLeading)
                    }
                    .offset(x: 100, y: -20)
                }
                
                
                ZStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                        
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(getFlowerDescriptions(for: flower.flowerName), id: \.self) { description in
                                    Text(description)
                                        .font(.custom("Georgia", size: 12))
                                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.2))
                                        .lineSpacing(3)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .frame(
                                width: geometry.size.width * 0.3,
                                height: geometry.size.height * 0.65,
                                alignment: .leading
                            )
                            .offset(x: 110, y: -20)
                            .id(flower.id)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                            
                            Spacer()
                        }
                        .padding(.top, geometry.size.height * 0.08)
                        
                        Spacer()
                        
                        
                        HStack {
                            Spacer()
                            if canGoNext {
                                Button(action: onNext) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))
                                }
                                .padding(.trailing, geometry.size.width * 0.1)
                                .padding(.bottom, geometry.size.height * 0.1)
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.5)
                }
            }
        }
    }
    
    private func getFlowerImageName(for flowerName: String) -> String? {
        switch flowerName {
        case "Rose": return "Rose"
        case "Jasmine": return "Jasmine"
        case "Lavender": return "Lavender"
        case "Hibiscus": return "Hibicus"
        default: return nil
        }
    }
    
    private func getFlowerDescriptions(for flowerName: String) -> [String] {
        switch flowerName {
        case "Rose":
            return [
                "Pink roses symbolize gentle emotions, appreciation, and grace.",
                "Yellow roses represent happiness, friendship, and positive energy.",
                "White roses stand for purity, sincerity, and new beginnings."
            ]
        case "Jasmine":
            return [
                "Jasmine represents purity, innocence, and grace.",
                "Often associated with spiritual ceremonies and sacred moments.",
                "Its delicate fragrance brings peace and tranquility to any space."
            ]
        case "Lavender":
            return [
                "Lavender brings serenity, calmness, and peace of mind.",
                "Known for its soothing properties and ability to reduce stress.",
                "Symbolizes devotion, grace, and elegance in floriography."
            ]
        case "Hibiscus":
            return [
                "Hibiscus expresses joy, celebration, and vibrant energy.",
                "Bright and cheerful, perfect for moments of happiness.",
                "Represents beauty, charm, and delicate beauty in many cultures."
            ]
        default:
            return ["A beautiful flower with special meaning."]
        }
    }
}

