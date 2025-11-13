//
//  SettingsView.swift
//  florist
//
//  Created by reynaldo on 04/11/25.
//
//
//import SwiftUI
//
//struct SettingsView: View {
//    var onDismiss: () -> Void
//    @State private var musicVolume: Double = 0.7
//    @State private var soundEffectsVolume: Double = 0.8
//    @State private var hapticFeedback: Bool = true
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                // Semi-transparent background
//                Color.black.opacity(0.4)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        onDismiss()
//                    }
//
//                // Settings content
//                VStack(spacing: 0) {
//                    // Header
//                    HStack {
//                        Text("⚙️ Settings")
//                            .font(.system(size: min(28, geometry.size.width * 0.035), weight: .bold))
//                            .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.3))
//
//                        Spacer()
//
//                        Button(action: {
//                            onDismiss()
//                        }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .font(.system(size: min(28, geometry.size.width * 0.035)))
//                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.4))
//                        }
//                    }
//                    .padding()
//                    .background(Color(red: 0.98, green: 0.94, blue: 0.90))
//
//                    // Settings options
//                    ScrollView {
//                        VStack(spacing: 25) {
//                            // Audio Section
//                            VStack(alignment: .leading, spacing: 15) {
//                                Text("Audio")
//                                    .font(.system(size: min(20, geometry.size.width * 0.025), weight: .semibold))
//                                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.3))
//
//                                // Music Volume
//                                VStack(alignment: .leading, spacing: 8) {
//                                    HStack {
//                                        Image(systemName: "music.note")
//                                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.5))
//                                        Text("Music Volume")
//                                            .font(.system(size: min(16, geometry.size.width * 0.02)))
//                                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.3))
//                                        Spacer()
//                                        Text("\(Int(musicVolume * 100))%")
//                                            .font(.system(size: min(14, geometry.size.width * 0.018), weight: .medium))
//                                            .foregroundColor(Color.gray)
//                                    }
//
//                                    Slider(value: $musicVolume, in: 0...1)
//                                        .accentColor(Color(red: 0.7, green: 0.5, blue: 0.6))
//                                }
//
//                                // Sound Effects Volume
//                                VStack(alignment: .leading, spacing: 8) {
//                                    HStack {
//                                        Image(systemName: "speaker.wave.2")
//                                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.5))
//                                        Text("Sound Effects")
//                                            .font(.system(size: min(16, geometry.size.width * 0.02)))
//                                            .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.3))
//                                        Spacer()
//                                        Text("\(Int(soundEffectsVolume * 100))%")
//                                            .font(.system(size: min(14, geometry.size.width * 0.018), weight: .medium))
//                                            .foregroundColor(Color.gray)
//                                    }
//
//                                    Slider(value: $soundEffectsVolume, in: 0...1)
//                                        .accentColor(Color(red: 0.7, green: 0.5, blue: 0.6))
//                                }
//                            }
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(15)
//
//                            // Haptic Feedback
//                            HStack {
//                                Image(systemName: "hand.tap")
//                                    .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.5))
//                                Text("Haptic Feedback")
//                                    .font(.system(size: min(16, geometry.size.width * 0.02)))
//                                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.3))
//
//                                Spacer()
//
//                                Toggle("", isOn: $hapticFeedback)
//                                    .labelsHidden()
//                                    .tint(Color(red: 0.7, green: 0.5, blue: 0.6))
//                            }
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(15)
//
//                            // About Section
//                            VStack(alignment: .leading, spacing: 10) {
//                                Text("About")
//                                    .font(.system(size: min(20, geometry.size.width * 0.025), weight: .semibold))
//                                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.3))
//
//                                VStack(alignment: .leading, spacing: 5) {
//                                    HStack {
//                                        Text("Version:")
//                                            .font(.system(size: min(14, geometry.size.width * 0.018)))
//                                            .foregroundColor(Color.gray)
//                                        Spacer()
//                                        Text("1.0.0")
//                                            .font(.system(size: min(14, geometry.size.width * 0.018), weight: .medium))
//                                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.3))
//                                    }
//
//                                    Divider()
//
//                                    HStack {
//                                        Text("Created with:")
//                                            .font(.system(size: min(14, geometry.size.width * 0.018)))
//                                            .foregroundColor(Color.gray)
//                                        Spacer()
//                                        Text("🌸 Love & Care")
//                                            .font(.system(size: min(14, geometry.size.width * 0.018), weight: .medium))
//                                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.3))
//                                    }
//                                }
//                            }
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(15)
//
//                            Spacer()
//                        }
//                        .padding()
//                    }
//                    .background(Color(red: 1.0, green: 0.98, blue: 0.95))
//                }
//                .frame(maxWidth: min(500, geometry.size.width * 0.9),
//                       maxHeight: min(550, geometry.size.height * 0.85))
//                .background(Color.white)
//                .cornerRadius(20)
//                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color(red: 0.8, green: 0.6, blue: 0.5), lineWidth: 3)
//                )
//                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
//            }
//        }
//        .statusBar(hidden: true)
//    }
//}
//
//#Preview {
//    SettingsView(onDismiss: {})
//}
//
