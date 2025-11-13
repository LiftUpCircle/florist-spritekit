//
//  FlowerSidebarView.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 06/11/25.
//

import SwiftUI

struct FlowerSidebarView: View {
    let flowers: [Flower]
    let currentIndex: Int
    let onFlowerSelected: (Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 1.0, green: 0.92, blue: 0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.7, green: 0.85, blue: 0.7), lineWidth: 4)
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                
                VStack(spacing: 20) {
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(Array(flowers.enumerated()), id: \.element.id) { index, flower in
                                Button(action: {
                                    onFlowerSelected(index)
                                }) {
                                    if let imageName = getFlowerImageName(for: flower.flowerName) {
                                        Image(imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 60)
                                            .opacity(index == currentIndex ? 1.0 : 0.6)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 15)
                .frame(width: geometry.size.width, alignment: .topLeading)
            }
            .padding(.leading, 15)
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
}

