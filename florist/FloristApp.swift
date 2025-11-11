//
//  FloristApp.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import SwiftUI

@main
struct FloristApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showSplashScreen = true

    var body: some Scene {
        WindowGroup {
            if showSplashScreen {
                SplashScreenView {
                    showSplashScreen = false
                }
                .preferredColorScheme(.light)
                .onAppear {
                    // Lock orientation to landscape
                    AppDelegate.orientationLock = .landscape
                }
            } else {
                MainMenuView()
                    .preferredColorScheme(.light)
            }
        }
    }
}
