import SwiftUI

struct TransitionLoadingView: View {
    @State private var flowerCount = 0
    @State private var opacity = 0.0

    let maxFlowers = 6

    var body: some View {
        ZStack {
            Color("LoadingBGColor")
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Loading...")
                    .font(.largeTitleGaegu)
                    .fontWeight(.bold)
                    .foregroundColor(Color("LoadingTextColor"))

                ZStack(alignment: .leading) {
                    Image("LoadingFrame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 100)

                    HStack(spacing: 8) {
                        ForEach(0..<maxFlowers, id: \.self) { index in
                            if index < flowerCount {
                                Image("LoadingBunga")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Color.clear
                                    .frame(width: 35, height: 35)
                            }
                        }
                    }
                    .padding(.leading, 22)
                }
            }
            .opacity(opacity)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }

            startFlowerAnimation()
        }
    }

    private func startFlowerAnimation() {
        for index in 0...maxFlowers {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    flowerCount = index
                }
            }
        }
    }
}

#Preview {
    TransitionLoadingView()
}
