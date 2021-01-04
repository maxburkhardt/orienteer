//
//  OrienteerAppClipApp.swift
//  OrienteerAppClip
//
//  Created by Maximilian Burkhardt on 1/3/21.
//

import SwiftUI

@main
struct OrienteerAppClipApp: App {
    @StateObject var userSettings = UserSettings()
    @StateObject var userLocation = UserLocation()
    let persistenceController = PersistenceController.shared
    let geocoder = Geocoder()
    let watchConnectionProvider = WatchConnectionProvider()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                OrienteerView(destinationPlaceType: "appclip", destinationPlaceId: "", geocoder: geocoder, userLocation: userLocation)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(userSettings)
                    .environmentObject(watchConnectionProvider)
            }
        }
    }
}
