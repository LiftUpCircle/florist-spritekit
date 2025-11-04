//
//  TypewriterViewModel.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import SwiftUI
import Combine

class TypewriterViewModel: ObservableObject {
    @Published var displayedText: String = ""
    @Published var isTypingComplete: Bool = false
    
    private var fullText: String = ""
    private var typingTimer: Timer?
    private var currentIndex: Int = 0
    
    var typingSpeed: TimeInterval = 0.05 // seconds per character
    
    func startTyping(text: String, speed: TimeInterval = 0.05, maxWidth: CGFloat = 0, font: UIFont = UIFont.systemFont(ofSize: 17)) {
        // Cancel any existing typing
        stopTyping()
        
        // Pre-calculate line breaks if maxWidth is provided
        if maxWidth > 0 {
            fullText = calculateLineBreaks(text: text, maxWidth: maxWidth, font: font)
        } else {
            fullText = text
        }
        
        typingSpeed = speed
        displayedText = ""
        currentIndex = 0
        isTypingComplete = false
        
        // Start typing animation
        typingTimer = Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { [weak self] _ in
            self?.typeNextCharacter()
        }
    }
    
    func completeTyping() {
        print("🔴 completeTyping() called")
        stopTyping()
        displayedText = fullText
        isTypingComplete = true
        print("🔴 Typing completed. displayedText length: \(displayedText.count), fullText length: \(fullText.count)")
    }
    
    func stopTyping() {
        typingTimer?.invalidate()
        typingTimer = nil
    }
    
    private func typeNextCharacter() {
        guard currentIndex < fullText.count else {
            completeTyping()
            return
        }
        
        let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
        displayedText.append(fullText[index])
        currentIndex += 1
    }
    
    func calculateLineBreaks(text: String, maxWidth: CGFloat, font: UIFont) -> String {
        // If text already has manual line breaks, respect them
        if text.contains("\n") {
            return text
        }
        
        let words = text.split(separator: " ", omittingEmptySubsequences: false)
        var lines: [String] = []
        var currentLine = ""
        
        for (_, word) in words.enumerated() {
            let wordString = String(word)
            let testLine = currentLine.isEmpty ? wordString : currentLine + " " + wordString
            
            let size = (testLine as NSString).size(withAttributes: [.font: font])
            
            if size.width <= maxWidth {
                currentLine = testLine
            } else {
                // Current line is full, start new line
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                }
                currentLine = wordString
            }
        }
        
        // Add the last line
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines.joined(separator: "\n")
    }
    
    deinit {
        stopTyping()
    }
}
