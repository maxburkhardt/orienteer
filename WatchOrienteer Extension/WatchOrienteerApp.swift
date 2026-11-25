//
//  WatchOrienteerApp.swift
//  WatchOrienteer
//

import SwiftUI

@main
struct WatchOrienteerApp: App {
    @StateObject private var phoneConnectionProvider = PhoneConnectionProvider()
    @StateObject private var userLocation = UserLocation()
    // OrienteerCompassView declares UserSettings as an environment object, so it must be provided.
    @StateObject private var userSettings = UserSettings()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ReadyView(phoneConnectionProvider: phoneConnectionProvider, userLocation: userLocation)
            }
            .environmentObject(userSettings)
        }
    }
}
