//
//  ToBeContinuedView.swift
//  florist
//
//  Created by reynaldo
//

import SwiftUI

/// A view that displays the "To Be Continued" screen after the closing story
struct ToBeContinuedView: View {
    @ObservedObject var flowCoordinator: GameFlowCoordinator
    
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark transparent overlay
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                
                // Centered "TO BE CONTINUE..." text
                VStack {
                    Spacer()
                    
                    Text("TO BE CONTINUE...")
                        .font(.custom("Gaegu-Bold", size: 48))
                        .foregroundColor(.white)
                        .tracking(4)
                        .opacity(textOpacity)
                    
                    Spacer()
                }
                
                // Back to Home Button - bottom right
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            flowCoordinator.returnToMainMenu()
                        }) {
                            Image("BackToHomeButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 50)
                        }
                        .opacity(buttonOpacity)
                        .padding(.trailing, 40)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            // Fade in the text
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                textOpacity = 1.0
            }
            
            // Fade in the button after text
            withAnimation(.easeIn(duration: 0.8).delay(1.5)) {
                buttonOpacity = 1.0
            }
        }
    }
}

#Preview {
    ToBeContinuedView(flowCoordinator: GameFlowCoordinator())
}
