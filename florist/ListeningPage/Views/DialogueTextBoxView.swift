//
//  DialogueTextBoxView.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import SwiftUI

struct DialogueTextboxView: View {
    let characterName: String
    let dialogue: String
    let typingSpeed: Double
    let shouldCompleteTyping: Bool
    let maxWidth: CGFloat
    let onTypingComplete: () -> Void
    let onTap: () -> Void
    
    @StateObject private var typewriter = TypewriterViewModel()
    @State private var processedDialogue: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(characterName)
                .font(.headline)
                .foregroundColor(.white)
            
            ZStack(alignment: .topLeading) {
                // Hidden text to set the size based on processed dialogue with line breaks
                Text(processedDialogue)
                    .font(.body)
                    .foregroundColor(.clear)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Visible typing text
                Text(typewriter.displayedText)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .fixedSize(horizontal: true, vertical: true)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.75))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    print("🔵 Dialogue tapped! isTypingComplete: \(typewriter.isTypingComplete)")
                    if !typewriter.isTypingComplete {
                        print("🟢 Completing typing animation")
                        typewriter.completeTyping()
                    } else {
                        print("🟡 Advancing to next scene")
                        onTap()
                    }
                }
        )
        .onAppear {
            processedDialogue = typewriter.calculateLineBreaks(text: dialogue, maxWidth: maxWidth, font: UIFont.systemFont(ofSize: 17))
            typewriter.startTyping(text: dialogue, speed: typingSpeed, maxWidth: maxWidth, font: UIFont.systemFont(ofSize: 17))
        }
        .onChange(of: dialogue) { oldValue, newValue in
            processedDialogue = typewriter.calculateLineBreaks(text: newValue, maxWidth: maxWidth, font: UIFont.systemFont(ofSize: 17))
            typewriter.startTyping(text: newValue, speed: typingSpeed, maxWidth: maxWidth, font: UIFont.systemFont(ofSize: 17))
        }
        .onChange(of: typewriter.isTypingComplete) { _, isComplete in
            if isComplete {
                onTypingComplete()
            }
        }
        .onChange(of: shouldCompleteTyping) { _, shouldComplete in
            if shouldComplete && !typewriter.isTypingComplete {
                typewriter.completeTyping()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(characterName) says: \(dialogue)")
    }
}

#Preview {
    ZStack {
        Color.gray
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            DialogueTextboxView(
                characterName: "Alice",
                dialogue: "Hello! Welcome to our story. This is a sample dialogue to demonstrate the textbox appearance.",
                typingSpeed: 0.05,
                shouldCompleteTyping: false,
                maxWidth: 300,
                onTypingComplete: { print("Typing complete") },
                onTap: { print("Dialogue tapped") }
            )
            .padding(.bottom, 80)
        }
    }
}
