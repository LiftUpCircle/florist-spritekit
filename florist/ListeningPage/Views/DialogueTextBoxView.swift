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
    let showTriangleIndicator: Bool
    let onTypingComplete: () -> Void
    let onTap: () -> Void

    // Convenience initializer with default showTriangleIndicator = true
    init(characterName: String,
         dialogue: String,
         typingSpeed: Double,
         shouldCompleteTyping: Bool,
         maxWidth: CGFloat,
         showTriangleIndicator: Bool = true,
         onTypingComplete: @escaping () -> Void,
         onTap: @escaping () -> Void) {
        self.characterName = characterName
        self.dialogue = dialogue
        self.typingSpeed = typingSpeed
        self.shouldCompleteTyping = shouldCompleteTyping
        self.maxWidth = maxWidth
        self.showTriangleIndicator = showTriangleIndicator
        self.onTypingComplete = onTypingComplete
        self.onTap = onTap
    }

    @StateObject private var typewriter = TypewriterViewModel()
    @State private var processedDialogue: String = ""
    @State private var showTriangle = false
    @EnvironmentObject private var textSizeManager: TextSizeManager

    // Display name with "(you)" indicator for Maria
    private var displayName: String {
        if characterName.lowercased().contains("maria") {
            return "\(characterName) (you)"
        }
        return characterName
    }

    // Check if this is Maria's dialogue
    private var isMaria: Bool {
        characterName.lowercased().contains("maria")
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text(displayName)
                    .font(.bodyGaegu)
                    .fontWeight(.semibold)
                    .foregroundColor(isMaria ? Color("TextPlayButton") : .primary)

                ZStack(alignment: .topLeading) {
                    // Hidden text to set the size based on processed dialogue with line breaks
                    Text(processedDialogue)
                        .font(.bodyGaegu)
                        .foregroundColor(.clear)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    // Visible typing text
                    Text(typewriter.displayedText)
                        .font(.bodyGaegu)
                        .foregroundColor(isMaria ? Color("TextPlayButton") : .primary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .fixedSize(horizontal: true, vertical: true)
            .padding(16)
            .padding(.trailing, 40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isMaria ? Color("DialogueTextboxBorder") : Color("DialogueTextbox"))
                    .stroke(isMaria ? Color("DialogueTextbox") : Color("DialogueTextboxBorder"), lineWidth: 5)
            )


            // Blinking triangle indicator (only show if showTriangleIndicator is true)
            if showTriangleIndicator && typewriter.isTypingComplete {
                Image(systemName: "play.fill")
                    .font(.bodyGaegu)
                    .foregroundColor(isMaria ? Color("TextPlayButton") : .primary)
//                    .shadow(color: .primary.opacity(0.4), radius: 2)
                    .opacity(showTriangle ? 1.0 : 0.5)
                    .padding(.trailing, 12)
                    .padding(.bottom, 12)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                            showTriangle = true
                        }
                    }
            }
        }
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
            processedDialogue = typewriter.calculateLineBreaks(text: dialogue, maxWidth: maxWidth, font: GaeguTypography.body)
            typewriter.startTyping(text: dialogue, speed: typingSpeed, maxWidth: maxWidth, font: GaeguTypography.body)
        }
        .onChange(of: dialogue) { oldValue, newValue in
            showTriangle = false
            processedDialogue = typewriter.calculateLineBreaks(text: newValue, maxWidth: maxWidth, font: GaeguTypography.body)
            typewriter.startTyping(text: newValue, speed: typingSpeed, maxWidth: maxWidth, font: GaeguTypography.body)
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
