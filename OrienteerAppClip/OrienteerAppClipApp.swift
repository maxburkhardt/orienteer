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

    /// Matches the location status screens in the full app's SearchView.
    private func statusIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 48))
            .foregroundStyle(.secondary)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if let locationAuthStatus = userLocation.locationStatus {
                    if locationAuthStatus == CLAuthorizationStatus.restricted || locationAuthStatus == CLAuthorizationStatus.denied {
                        ContentUnavailableView {
                            statusIcon("xmark.octagon")
                        } description: {
                            Text("Orienteer requires location access to function.")
                        } actions: {
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                Link("Open Settings", destination: settingsURL)
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                    } else {
                        OrienteerView(destinationPlaceType: "appclip", destinationPlaceId: "", geocoder: geocoder, userLocation: userLocation)
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .environmentObject(userSettings)
                            .environmentObject(watchConnectionProvider)
                    }
                } else {
                    ContentUnavailableView {
                        statusIcon("exclamationmark.triangle")
                    } description: {
                        Text("Could not load location authorization status.")
                    }
                }
            }
        }
    }
}
