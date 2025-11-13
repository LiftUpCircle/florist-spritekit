import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            Image("SplashScreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(opacity)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }

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
