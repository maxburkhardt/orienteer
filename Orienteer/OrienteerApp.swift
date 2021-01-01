//
//  OrienteerApp.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import SwiftUI

@main
struct OrienteerApp: App {
    @StateObject var userSettings = UserSettings()
    @StateObject var userLocation = UserLocation()
    let persistenceController = PersistenceController.shared
    let geocoder = Geocoder()

    var body: some Scene {
        WindowGroup {
            SearchView(userLocation: userLocation, geocoder: geocoder)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(userSettings)
        }
    }
}
