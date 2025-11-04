//
//  CompletionOverlay.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import SwiftUI

struct CompletionOverlay: View {
    let onRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Story Complete")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Button(action: onRestart) {
                    Text("Restart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .accessibilityLabel("Restart Story")
                .accessibilityHint("Restarts the story from the beginning")
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    CompletionOverlay(onRestart: {
        print("Restart tapped")
    })
}


