//
//  FlowerBookView.swift
//  florist
//
//  Created by AI on 04/11/25.
//

import SwiftUI

struct FlowerBookView: View {
    var onDismiss: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }

                // Book content
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("🌸 Floriography Guide")
                            .font(.system(size: min(28, geometry.size.width * 0.035), weight: .bold))
                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.3))

                        Spacer()

                        Button(action: {
                            onDismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: min(28, geometry.size.width * 0.035)))
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.4))
                        }
                    }
                    .padding()
                    .background(Color(red: 0.98, green: 0.94, blue: 0.90))

                    // Book pages
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(FlowerDatabase.shared.availableFlowers) { flower in
                                FlowerEntryView(flower: flower)
                            }
                        }
                        .padding()
                    }
                    .background(Color(red: 1.0, green: 0.98, blue: 0.95))
                }
                .frame(maxWidth: min(600, geometry.size.width * 0.9),
                       maxHeight: min(500, geometry.size.height * 0.85))
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.8, green: 0.6, blue: 0.5), lineWidth: 3)
                )
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .statusBar(hidden: true)
    }
}

struct FlowerEntryView: View {
    let flower: Flower

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: geometry.size.width * 0.05) {
                // Flower image
                if let imageName = getFlowerImageName(for: flower.flowerName) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: min(100, geometry.size.width * 0.25),
                               height: min(100, geometry.size.width * 0.25))
                } else {
                    // Fallback colored circle
                    Circle()
                        .fill(Color(flower.flowerColor))
                        .frame(width: min(100, geometry.size.width * 0.25),
                               height: min(100, geometry.size.width * 0.25))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(flower.flowerName)
                        .font(.system(size: min(24, geometry.size.width * 0.06), weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.3))

                    HStack {
                        Text("Emotion:")
                            .font(.system(size: min(16, geometry.size.width * 0.04), weight: .semibold))
                            .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.4))

                        Text(flower.emotion)
                            .font(.system(size: min(16, geometry.size.width * 0.04), weight: .medium))
                            .foregroundColor(Color(flower.flowerColor))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(flower.flowerColor).opacity(0.2))
                            .cornerRadius(8)
                    }

                    Text(getFlowerDescription(for: flower.flowerName))
                        .font(.system(size: min(14, geometry.size.width * 0.035)))
                        .foregroundColor(Color.gray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .frame(height: 120)
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
    
    private func getFlowerDescription(for flowerName: String) -> String {
        switch flowerName {
        case "Rose": return "Symbol of love and passion. Perfect for romantic occasions."
        case "Jasmine": return "Represents purity and innocence. Often used in spiritual ceremonies."
        case "Lavender": return "Brings serenity and calmness. Known for its soothing properties."
        case "Hibiscus": return "Expresses joy and celebration. Bright and cheerful."
        default: return "A beautiful flower with special meaning."
        }
    }
}

#Preview {
    FlowerBookView(onDismiss: {})
}

