//
//  SettingsManager.swift
//  florist
//
//  Created by Farrah Allysha Maharani on 04/11/25.
//

import Foundation
import UIKit
import AVFoundation

class SettingsManager {
    static let shared = SettingsManager()

    private let sfxVolumeKey = "sfxVolume"
    private let musicVolumeKey = "musicVolume"
    private let vibrationEnabledKey = "vibrationEnabled"
    private let subtitlesEnabledKey = "subtitlesEnabled"
    private let cutscenesEnabledKey = "cutscenesEnabled"


    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?

    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured successfully")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - SFX (Sound Effects) Settings
    
    var sfxVolume: Float {
        get {
            if UserDefaults.standard.object(forKey: sfxVolumeKey) == nil {
                return 1.0
            }
            return UserDefaults.standard.float(forKey: sfxVolumeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: sfxVolumeKey)
        }
    }
    
    var isSoundEnabled: Bool {
        return sfxVolume > 0.0
    }
    
    func toggleSound() {
        sfxVolume = sfxVolume > 0.0 ? 0.0 : 1.0
    }
    
    // MARK: - Preload & Play Sound Effects

    func preloadSound(named soundName: String, withExtension ext: String = "mp3") {
        var url = Bundle.main.url(forResource: "AudioResources/SFX/\(soundName)", withExtension: ext)

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
            audioPlayers[soundName] = player
            print("✅ Preloaded sound: \(soundName).\(ext)")
        } catch {
            print("❌ Failed to load sound \(soundName).\(ext): \(error)")
        }
    }

    func playSound(named soundName: String, volume: Float? = nil) {
        guard sfxVolume > 0.0 else { return }

        if let player = audioPlayers[soundName] {
            player.volume = volume ?? sfxVolume
            player.currentTime = 0.0
            player.play()
            print("🔊 Playing sound: \(soundName) at volume \(player.volume)")
        } else {
            print("⚠️ Sound \(soundName) not preloaded, attempting to load and play.")
            preloadSound(named: soundName)
            audioPlayers[soundName]?.volume = volume ?? sfxVolume
            audioPlayers[soundName]?.play()
        }
    }

    func stopSound(named soundName: String) {
        audioPlayers[soundName]?.stop()
    }

    func stopAllSounds() {
        audioPlayers.values.forEach { $0.stop() }
    }

    func playPageFlip(volume: Float? = nil) {
        playSound(named: "flippingbook", volume: volume)
    }
    
    // MARK: - Music Settings
    
    var musicVolume: Float {
        get {
            if UserDefaults.standard.object(forKey: musicVolumeKey) == nil {
                // Default to 1.0
                return 1.0
            }
            return UserDefaults.standard.float(forKey: musicVolumeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: musicVolumeKey)
            
            musicPlayer?.volume = newValue
        }
    }
    
    func setMusicVolume(_ volume: Float) {
        musicVolume = max(0.0, min(1.0, volume))
    }
    
    func playMusic(named fileName: String, ofType type: String = "mp3", loops: Int = -1) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }

        stopMusic()

        guard let path = Bundle.main.path(forResource: fileName, ofType: type) else {
            print("Music file not found: \(fileName).\(type)")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.volume = musicVolume
            musicPlayer?.numberOfLoops = loops
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("Error playing music: \(error.localizedDescription)")
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }
    
    // MARK: - Vibration Settings
    
    var isVibrationEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: vibrationEnabledKey) == nil {
                // Default to true
                return true
            }
            return UserDefaults.standard.bool(forKey: vibrationEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: vibrationEnabledKey)
        }
    }
    
    func toggleVibration() {
        isVibrationEnabled.toggle()
    }
    
    func triggerVibration(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isVibrationEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Subtitles Settings
    
    var isSubtitlesEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: subtitlesEnabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: subtitlesEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: subtitlesEnabledKey)
        }
    }
    
    func toggleSubtitles() {
        isSubtitlesEnabled.toggle()
    }
    
    // MARK: - Cutscenes Settings
    
    var isCutscenesEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: cutscenesEnabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: cutscenesEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: cutscenesEnabledKey)
        }
    }
    
    func toggleCutscenes() {
        isCutscenesEnabled.toggle()
    }
}

