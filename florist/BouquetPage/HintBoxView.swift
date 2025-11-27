//
//  HintBoxView.swift
//  florist
//
//  Created on 18/11/25.
//

import SwiftUI

struct HintBoxView: View {
    let characterName: String
    let dialogue: String
    let maxWidth: CGFloat
    @Binding var isMinimized: Bool
    @State private var isPulsing: Bool = false

    var body: some View {
        if isMinimized {
            minimizedHintButton()
        } else {
            expandedHintBox()
        }
    }

    @ViewBuilder
    private func minimizedHintButton() -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isMinimized = false
                isPulsing = false
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.custom("Gaegu-Bold", fixedSize: 17))
                    .fontWeight(.bold)
                    .foregroundColor(Color("DialogueTextboxBorder"))

                Text("Hint")
                    .font(.custom("Gaegu-Bold", fixedSize: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("DialogueTextbox"))
                    .stroke(Color("DialogueTextboxBorder"), lineWidth: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPulsing ? 1.05 : 1.0)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    @ViewBuilder
    private func expandedHintBox() -> some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(characterName)
                    .font(.bodyGaegu)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(dialogue)
                    .font(.bodyGaegu)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isMinimized = true
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color("DialogueTextboxBorder"))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .frame(maxWidth: maxWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("DialogueTextbox"))
                .stroke(Color("DialogueTextboxBorder"), lineWidth: 5)
        )
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
}

#Preview {
    VStack {
        Spacer()
        HStack {
            Spacer()
            HintBoxView(
                characterName: "Hint",
                dialogue: "Drag flowers from your inventory to create a beautiful bouquet.",
                maxWidth: 400,
                isMinimized: .constant(false)
            )
            .padding(.trailing, 20)
        }
        .padding(.top, 20)
        Spacer()
    }
    .background(Color.gray)
}