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
    
    
    private var audioPlayer: AVAudioPlayer?
    private var musicPlayer: AVAudioPlayer?
    
    private init() {
        // initalization kalo ada liat tar
    }
    
    // MARK: - SFX (Sound Effects) Settings
    
    var sfxVolume: Float {
        get {
            if UserDefaults.standard.object(forKey: sfxVolumeKey) == nil {
                // Default  1.0
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
    
    func playSound(named fileName: String, ofType type: String = "mp3") {
        guard sfxVolume > 0.0 else { return }
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: type) else {
            print("Sound file not found: \(fileName).\(type)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = sfxVolume
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
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
        guard let path = Bundle.main.path(forResource: fileName, ofType: type) else {
            print("Music file not found: \(fileName).\(type)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.volume = musicVolume
            musicPlayer?.numberOfLoops = loops
            musicPlayer?.play()
        } catch {
            print("Error playing music: \(error.localizedDescription)")
        }
    }
    
    func stopMusic() {
        musicPlayer?.stop()
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
                // Default to true if not set
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
                // Default to true
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

