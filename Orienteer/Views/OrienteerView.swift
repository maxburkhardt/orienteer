//
//  OrienteerView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/20/20.
//

import CoreData
import CoreLocation
import StoreKit
import SwiftUI

struct OrienteerView: View {
    var destinationPlaceType: String
    var destinationPlaceId: String
    var geocoder: Geocoder
    @ObservedObject var userLocation: UserLocation
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.verticalSizeClass) private var sizeClass
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var watchConnectionProvider: WatchConnectionProvider
    @State private var destinationPlace: NavigablePlace? = nil {
        didSet {
            if let place = destinationPlace {
                #if !APPCLIP
                    watchConnectionProvider.synchronizedPlace = place
                #endif
            }
        }
    }

    @State private var alertMessage = ""
    @State private var appStoreOverlayPresented = false
    @State private var adjustmentMode = NavigationAdjustmentMode.heading

    private var bearing: DegreesFromNorth? {
        destinationPlace != nil ? userLocation.bearingTo(destination: destinationPlace!.coordinates) : nil
    }

    private var distance: CLLocationDistance? {
        destinationPlace != nil ? userLocation.distanceTo(destination: destinationPlace!.coordinates) : nil
    }

    private func savePlace(name: String, address: String?, latitude: Double, longitude: Double) -> NavigablePlace {
        let savedPlace = NavigablePlace(context: viewContext)
        savedPlace.name = name
        savedPlace.address = address
        savedPlace.latitude = latitude
        savedPlace.longitude = longitude
        savedPlace.timestamp = Date()
        savedPlace.id = UUID()
        do {
            if userSettings.history {
                try viewContext.save()
            }
        } catch {
            let nsError = error as NSError
            alertMessage = "Failed to save navigable place: \(nsError)"
        }
        return savedPlace
    }

    private func parseOrienteerUrl(url: URL) {
        let errorMessage = "Could not load destination info from App Clip."
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            alertMessage = errorMessage
            return
        }
        guard let latitudeStr = components.queryItems?.first(where: { $0.name == "p" })?.value else {
            alertMessage = errorMessage
            return
        }
        guard let longitudeStr = components.queryItems?.first(where: { $0.name == "p1" })?.value else {
            alertMessage = errorMessage
            return
        }
        guard let latitudeUnconverted = Double(latitudeStr) else {
            alertMessage = errorMessage
            return
        }
        guard let longitudeUnconverted = Double(longitudeStr) else {
            alertMessage = errorMessage
            return
        }
        let latitude = (latitudeUnconverted / pow(10, 6)) - 90.0
        let longitude = (longitudeUnconverted / pow(10, 6)) - 180.0
        if let units = components.queryItems?.first(where: { $0.name == "p2" })?.value {
            if units == "0" {
                userSettings.units = DistanceUnits.metric
            } else if units == "1" {
                userSettings.units = DistanceUnits.imperial
            }
        }
        let name = components.queryItems?.first(where: { $0.name == "p3" })?.value
        destinationPlace = savePlace(name: name ?? "App Clip Destination", address: nil, latitude: latitude, longitude: longitude)
    }

    var body: some View {
        let showAlertBinding = Binding<Bool>(get: {
            alertMessage != ""
        }, set: { _ in
            alertMessage = ""
        })
        let adjustment = userSettings.speedAdjustment ? userLocation.getAdjustmentBinding() : $adjustmentMode
        VStack {
            if sizeClass != .compact {
                // Portrait layout
                OrienteerCompassView(bearing: bearing, userLocation: userLocation, adjustmentMode: adjustment)
                    .padding(.bottom, 40.0)
                OrienteerTextView(bearing: bearing, distance: distance, userLocation: userLocation)
                #if APPCLIP
                    Button(action: { appStoreOverlayPresented = true }) {
                        Text("Get Orienteer")
                    }
                    .padding(.top, 20.0)
                    .appStoreOverlay(isPresented: $appStoreOverlayPresented) {
                        SKOverlay.AppClipConfiguration(position: .bottom)
                    }
                #endif
            } else {
                VStack {
                    HStack {
                        OrienteerCompassView(bearing: bearing, userLocation: userLocation, adjustmentMode: adjustment)
                            .padding(.trailing, 40.0)
                        OrienteerTextView(bearing: bearing, distance: distance, userLocation: userLocation)
                    }
                }
            }
        }
        .navigationTitle(destinationPlace?.name ?? "Loading...")
        .onAppear {
            geocoder.pushErrorHandler(handler: { message in alertMessage = message })
            if userSettings.disableScreenDim {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            #if !APPCLIP
                if !watchConnectionProvider.isConnected {
                    watchConnectionProvider.connect(userSettings: userSettings)
                }
            #endif
            switch destinationPlaceType {
            case "googleplace":
                geocoder.placeDetails(placeId: destinationPlaceId, callback: { (placeResponse: PlaceDetailsResponse) -> Void in
                    let place = placeResponse.result
                    // First, check to see if we've been to this place before (to avoid history duplicates)
                    let duplicateFetch = NSFetchRequest<NavigablePlace>(entityName: "NavigablePlace")
                    duplicateFetch.predicate = NSPredicate(format: "name == %@ && latitude == %@ && longitude == %@", place.name, String(place.coordinates.coordinate.latitude), String(place.coordinates.coordinate.longitude))
                    do {
                        let duplicates = try viewContext.fetch(duplicateFetch)
                        if let duplicate = duplicates.first {
                            // There was a previous place with the same name and coordinates, so just use that
                            duplicate.timestamp = Date()
                            if userSettings.history {
                                try viewContext.save()
                            }
                            destinationPlace = duplicate
                        } else {
                            // There was not a previous place with these attributes, so create a new one
                            destinationPlace = savePlace(name: place.name, address: place.formattedAddress, latitude: place.coordinates.coordinate.latitude, longitude: place.coordinates.coordinate.longitude)
                        }
                    } catch {
                        // We weren't able to check for duplicates for some reason, so let's just forge ahead with a new NavigablePlace
                        let nsError = error as NSError
                        print("Failed to check for duplicates: \(nsError)")
                        destinationPlace = savePlace(name: place.name, address: place.formattedAddress, latitude: place.coordinates.coordinate.latitude, longitude: place.coordinates.coordinate.longitude)
                    }
                })
            case "history":
                let historyFetch = NSFetchRequest<NavigablePlace>(entityName: "NavigablePlace")
                historyFetch.predicate = NSPredicate(format: "id == %@", destinationPlaceId)
                do {
                    let fetchedPlace = try viewContext.fetch(historyFetch).first
                    fetchedPlace?.timestamp = Date()
                    if userSettings.history {
                        try viewContext.save()
                    }
                    destinationPlace = fetchedPlace
                } catch {
                    alertMessage = "Unable to load place from local storage"
                }
            case "coordinates":
                destinationPlace = savePlace(name: destinationPlaceId, address: nil, latitude: Double(destinationPlaceId.split(separator: ",").first!)!, longitude: Double(destinationPlaceId.split(separator: ",").last!)!)
            case "appclip":
                if destinationPlaceId != "" {
                    if let constructedUrl = URL(string: destinationPlaceId) {
                        parseOrienteerUrl(url: constructedUrl)
                    }
                }
            default:
                alertMessage = "Unknown place ID (\(destinationPlaceId)) passed to the OrienteerView"
            }
        }
        .onDisappear {
            geocoder.popErrorHandler()
            UIApplication.shared.isIdleTimerDisabled = false
            #if !APPCLIP
                watchConnectionProvider.synchronizedPlace = nil
            #endif
        }
        .onContinueUserActivity("NSUserActivityTypeBrowsingWeb", perform: { activity in
            guard activity.activityType == NSUserActivityTypeBrowsingWeb else { return }
            guard let incomingURL = activity.webpageURL else { return }
            parseOrienteerUrl(url: incomingURL)
        })
        .alert(isPresented: showAlertBinding) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct OrienteerView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerView(destinationPlaceType: "history", destinationPlaceId: "F8CDB8FA-84C5-4CB1-9651-118D44D5BEE0", geocoder: Geocoder(), userLocation: UserLocation())
            .environmentObject(UserSettings())
            .environmentObject(WatchConnectionProvider())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
