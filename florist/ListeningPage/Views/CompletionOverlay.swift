//
//  CompletionOverlay.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import SwiftUI

struct CompletionOverlay: View {
    let onRestart: () -> Void
    let buttonText: String
    
    init(onRestart: @escaping () -> Void, buttonText: String = "Restart") {
        self.onRestart = onRestart
        self.buttonText = buttonText
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Story Complete")
                    .font(.largeTitleGaegu)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Button(action: onRestart) {
                    Text(buttonText)
                        .font(.bodyGaegu)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .accessibilityLabel(buttonText)
                .accessibilityHint("Continue to arrange the bouquet")
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


