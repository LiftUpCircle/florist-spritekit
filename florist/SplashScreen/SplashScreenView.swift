import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var letterOffsets: [CGFloat] = Array(repeating: 0, count: 12)  // 11 letters total

    var onComplete: () -> Void
    
    let text = "Dear Bouquet"
    let letters = Array("Dear Bouquet")

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            Image("SplashScreen")
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
                        .foregroundColor(.primary)
                        .offset(y: letterOffsets[index])
                }
            }
            .zIndex(999)
            .offset(y: 100)
            .opacity(opacity)
        }
        .ignoresSafeArea()
        .onAppear {
            // Fade in background and text
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }
            
            // Start wave animation for each letter
            for index in 0..<letters.count {
                let delay = Double(index) * 0.1  // Stagger each letter
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        letterOffsets[index] = -15  // Bounce up 15 points
                    }
                }
            }

            // Fade out everything
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isActive = true
                    onComplete()
                }
            }
        }
    }
}
