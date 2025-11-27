//
//  ToBeContinuedView.swift
//  florist
//
//  Created by AI Assistant
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
                            HStack(spacing: 8) {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text("Back to Home")
                                    .font(.custom("Gaegu-Bold", size: 18))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    )
                            )
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
