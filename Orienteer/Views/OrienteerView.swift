//
//  OrienteerView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/20/20.
//

import CoreData
import CoreLocation
import SwiftUI

struct OrienteerView: View {
    var destinationPlaceType: String
    var destinationPlaceId: String
    var geocoder: Geocoder
    @ObservedObject var userLocation: UserLocation
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.verticalSizeClass) private var sizeClass
    @EnvironmentObject var userSettings: UserSettings
    @State private var destinationPlace: NavigablePlace? = nil
    @State private var orientation = UIDevice.current.orientation
    @State private var alertMessage = ""

    private var bearing: DegreesFromNorth? {
        destinationPlace != nil ? userLocation.bearingTo(destination: destinationPlace!.coordinates) : nil
    }

    private var distance: CLLocationDistance? {
        destinationPlace != nil ? userLocation.distanceTo(destination: destinationPlace!.coordinates) : nil
    }

    private let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()

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

    var body: some View {
        let showAlertBinding = Binding<Bool>(get: {
            alertMessage != ""
        }, set: { _ in
            alertMessage = ""
        })
        VStack {
            if sizeClass != .compact {
                // Portrait layout
                OrienteerCompassView(bearing: bearing).environmentObject(userLocation)
                    .padding(.bottom, 40.0)
                OrienteerTextView(bearing: bearing, distance: distance, userSettings: userSettings).environmentObject(userLocation)
            } else {
                HStack {
                    OrienteerCompassView(bearing: bearing).environmentObject(userLocation)
                        .padding(.trailing, 40.0)
                    OrienteerTextView(bearing: bearing, distance: distance, userSettings: userSettings).environmentObject(userLocation)
                }
            }
        }
        .navigationTitle(destinationPlace?.name ?? "Loading...")
        .onAppear {
            geocoder.pushErrorHandler(handler: { message in alertMessage = message })
            userLocation.updateOrientation(newOrientation: self.orientation.convertToCLDeviceOrientation())
            if userSettings.disableScreenDim {
                UIApplication.shared.isIdleTimerDisabled = true
            }
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
            default:
                alertMessage = "Unknown place ID (\(destinationPlaceId)) passed to the OrienteerView"
            }
        }
        .onReceive(orientationChanged, perform: { _ in
            let newOrientation = UIDevice.current.orientation
            // We support "fully inverted" on iPad, but not on iPhone, where it's disabled
            if newOrientation != UIDeviceOrientation.portraitUpsideDown || UIDevice.current.userInterfaceIdiom == .pad {
                self.orientation = newOrientation
                userLocation.updateOrientation(newOrientation: newOrientation.convertToCLDeviceOrientation())
            }
        })
        .onDisappear {
            geocoder.popErrorHandler()
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .alert(isPresented: showAlertBinding) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct OrienteerView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerView(destinationPlaceType: "history", destinationPlaceId: "F8CDB8FA-84C5-4CB1-9651-118D44D5BEE0", geocoder: Geocoder(), userLocation: UserLocation())
            .environmentObject(UserSettings())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
