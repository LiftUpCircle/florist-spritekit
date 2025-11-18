//
//  SoundManager.swift
//  Dear Bouquet
//
//  Created by Hafi on 18/11/25.
//

import AVFoundation
import Foundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: [String: AVAudioPlayer] = [:]
    private init() {
        // Configure audio session to mix with other audio (BGM)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
    
    // Preload a sound file from AudioResources folder
    func preloadSound(named soundName: String, withExtension ext: String = "mp3") {
        // Try loading from AudioResources/SFX/ first
        var url = Bundle.main.url(forResource: "AudioResources/SFX/\(soundName)", withExtension: ext)
        
        // If not found, try direct path
        if url == nil {
            url = Bundle.main.url(forResource: soundName, withExtension: ext)
        }
        
        guard let soundURL = url else {
            print("❌ Sound file not found: \(soundName).\(ext)")
            print("   Tried: AudioResources/SFX/\(soundName).\(ext)")
            print("   And: \(soundName).\(ext)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.prepareToPlay()
            audioPlayer[soundName] = player
            print("✅ Preloaded sound: \(soundName).\(ext)")
        } catch {
            print("❌ Failed to load sound \(soundName).\(ext): \(error)")
        }
    }
    
    // Play a sound file
    func playSound(named soundName: String, volume: Float = 1.0) {
        if let player = audioPlayer[soundName] {
            player.volume = volume
            player.currentTime = 0.0 // Restart from beginning
            player.play()
            print("🔊 Playing sound: \(soundName) at volume \(volume)")
        } else {
            print("⚠️ Sound \(soundName) not preloaded, attempting to load and play.")
            preloadSound(named: soundName)
            audioPlayer[soundName]?.volume = volume
            audioPlayer[soundName]?.play()
        }
    }
    
    // Stop a sound
    func stopSound(named soundName: String) {
        audioPlayer[soundName]?.stop()
    }
    
    // Stop all sounds
    func stopAllSounds() {
        audioPlayer.values.forEach { $0.stop() }
    }
    
    /// Play the page flip sound effect
    func playPageFlip(volume: Float = 1.0) {
        playSound(named: "flippingbook", volume: volume)
    }
    
    // MARK: - Debug Helper
    
    /// Check if a sound file exists in the bundle
//    func debugCheckFile(named soundName: String, withExtension ext: String = "mp3") {
//        print("\n🔍 Checking for sound file: \(soundName).\(ext)")
//        
//        // Check AudioResources/SFX/
//        if let url1 = Bundle.main.url(forResource: "AudioResources/SFX/\(soundName)", withExtension: ext) {
//            print("✅ Found at: AudioResources/SFX/\(soundName).\(ext)")
//            print("   Full path: \(url1.path)")
//            return
//        }
//        
//        // Check direct path
//        if let url2 = Bundle.main.url(forResource: soundName, withExtension: ext) {
//            print("✅ Found at: \(soundName).\(ext)")
//            print("   Full path: \(url2.path)")
//            return
//        }
//        
//        print("❌ File not found in bundle!")
//        print("   Make sure the file is added to your Xcode target")
//    }
}
