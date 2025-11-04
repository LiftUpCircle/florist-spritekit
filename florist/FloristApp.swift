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

    var body: some Scene {
        WindowGroup {
            VNSceneView()
                .preferredColorScheme(.light)
                .onAppear {
                    // Lock orientation to landscape
                    AppDelegate.orientationLock = .landscape
                }
        }
    }
}
