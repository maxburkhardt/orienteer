//
//  WatchOrienteerApp.swift
//  WatchOrienteer
//

import SwiftUI

@main
struct WatchOrienteerApp: App {
    @StateObject private var phoneConnectionProvider = PhoneConnectionProvider()
    @StateObject private var userLocation = UserLocation()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ReadyView(phoneConnectionProvider: phoneConnectionProvider, userLocation: userLocation)
            }
        }
    }
}
