import SwiftUI

struct TransitionLoadingView: View {
    @State private var letterOffsets: [CGFloat] = Array(repeating: 0, count: 12)
    @State private var opacity = 0.0

    let text = "Dear Bouquet"
    let letters = Array("Dear Bouquet")

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            Image("LoadingScreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(opacity)

            // Each letter animated individually
            HStack(spacing: 2) {
                ForEach(0..<letters.count, id: \.self) { index in
                    Text(String(letters[index]))
                        .font(.largeTitleGaegu)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .offset(y: letterOffsets[index])
                }
            }
            .zIndex(999)
            .offset(y: 100)
            .opacity(opacity)
        }
        .ignoresSafeArea()
        .onAppear {
            // Fade in
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }

            // Start wave animation for each letter
            for index in 0..<letters.count {
                let delay = Double(index) * 0.1

                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        letterOffsets[index] = -15
                    }
                }
            }
        }
    }
}