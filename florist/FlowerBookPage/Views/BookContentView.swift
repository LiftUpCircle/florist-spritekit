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
            ZStack {
                HStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        ZStack(alignment: .topLeading) {
                            VStack(alignment: .leading, spacing: 20) {
                                if let imageName = getFlowerImageName(for: flower.flowerName) {
                                    Image(imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width * 0.35,
                                               height: geometry.size.width * 0.35)
                                }
                                //                            Text(flower.flowerName)
                                //                                .font(.custom("Georgia", size: 30))
                                //                                .foregroundColor(Color(red: 0.4, green: 0.25, blue: 0.2))
                                //                                .fontWeight(.bold)
                                //                                .italic()
                                //                            if canGoPrevious {
                                //                                Button(action: onPrevious) {
                                //                                    Image(systemName: "chevron.left")
                                //                                        .font(.system(size: 24, weight: .bold))
                                //                                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))
                                //                                }
                                //                                .padding(.top, 10)
                                //                            }
                            }
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.5, alignment: .topLeading)
                        }
                        .offset(x: 35, y: -15)
                    }
                    
                    
                    ZStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                            
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 28) {
                                    ForEach(getFlowerDescriptions(for: flower.flowerName), id: \.self) { description in
                                        Text(description)
                                            .font(.custom("Georgia", size: 10))
                                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.2))
                                            .lineSpacing(3)
                                            .multilineTextAlignment(.center)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 10)
                                            .background(
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color(red: 1.0, green: 0.95, blue: 0.9))
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color(red: 0.8, green: 0.7, blue: 0.6), lineWidth: 2)
                                                }
                                            )
                                            .rotationEffect(.degrees(Double.random(in: -5...5)))
                                    }
                                }
                                .frame(
                                    width: geometry.size.width * 0.4,
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
                            //                        HStack {
                            //                            Spacer()
                            //                            if canGoNext {
                            //                                Button(action: onNext) {
                            //                                    Image(systemName: "chevron.right")
                            //                                        .font(.system(size: 24, weight: .bold))
                            //                                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))
                            //                                }
                            //                                .padding(.trailing, geometry.size.width * 0.1)
                            //                                .padding(.bottom, geometry.size.height * 0.1)
                            //                            }
                            //                        }
                        }
                        .frame(width: geometry.size.width * 0.5)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                
                HStack {
                    // Previous Button
                    if canGoPrevious {
                        Button(action: onPrevious) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))
                        }
                        .padding(.leading, 15)
                    }
                    
                    Spacer()
                    
                    // Next Button
                    if canGoNext {
                        Button(action: onNext) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.3))
                        }
                        .padding(.trailing, 15)
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                //                .offset(y: 140)
            }
            
        }
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
        case "Carnation":
            return [
                "Carnations symbolize joy, fascination, and distinction.",
                "Pink carnations represent gratitude and admiration.",
                "White carnations signify pure love and good luck."
            ]
        case "Lily":
            return [
                "Lilies represent hope, purity, and renewal.",
                "White lilies symbolize modesty and virginity.",
                "Often used in celebrations and solemn occasions."
            ]
        case "Tulip":
            return [
                "Tulips symbolize elegance, grace, and perfect love.",
                "Yellow tulips represent cheerfulness and sunshine.",
                "Red tulips are a declaration of love."
            ]
        default:
            return ["A beautiful flower with special meaning."]
        }
    }
}

