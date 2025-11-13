//
//  ToastView.swift
//  florist
//
//  Created by reynaldo on 13/11/25.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)

            Text(message)
                .font(.bodyGaegu)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.85))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
        )
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let icon: String
    let duration: TimeInterval

    func body(content: Content) -> some View {
        ZStack {
            content

            if isShowing {
                VStack {
                    ToastView(message: message, icon: icon)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 50)

                    Spacer()
                }
                .zIndex(999)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String, icon: String = "checkmark.circle.fill", duration: TimeInterval = 3.0) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message, icon: icon, duration: duration))
    }
}

#Preview {
    VStack {
        Text("Content")
    }
    .toast(isShowing: .constant(true), message: "Bouquet saved to memories!")
}
