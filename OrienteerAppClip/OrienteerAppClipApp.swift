//
//  OrienteerAppClipApp.swift
//  OrienteerAppClip
//
//  Created by Maximilian Burkhardt on 1/3/21.
//

import CoreLocation
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
                if let locationAuthStatus = userLocation.locationStatus {
                    if locationAuthStatus == CLAuthorizationStatus.restricted || locationAuthStatus == CLAuthorizationStatus.denied {
                        VStack {
                            Image(systemName: "xmark.octagon")
                                .font(.system(size: 100))
                                .padding(.bottom, 20.0)
                            Text("Orienteer requires location access to function.")
                        }
                    } else {
                        OrienteerView(destinationPlaceType: "appclip", destinationPlaceId: "", geocoder: geocoder, userLocation: userLocation)
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .environmentObject(userSettings)
                            .environmentObject(watchConnectionProvider)
                    }
                } else {
                    Text("Could not load location authorization status.")
                }
            }
        }
    }
}
