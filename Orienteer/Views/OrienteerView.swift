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
    @EnvironmentObject var userSettings: UserSettings
    @State private var destinationPlace: NavigablePlace? = nil
    @State private var orientation = UIDevice.current.orientation

    private var bearing: DegreesFromNorth? {
        destinationPlace != nil ? userLocation.bearingTo(destination: destinationPlace!.coordinates) : nil
    }

    private var distance: CLLocationDistance? {
        destinationPlace != nil ? userLocation.distanceTo(destination: destinationPlace!.coordinates) : nil
    }

    private let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()

    var body: some View {
        VStack {
            Image(systemName: "location.north.line")
                .rotationEffect(bearing != nil ? Angle(degrees: bearing! - (userLocation.lastHeading?.trueHeading ?? 0)) : .zero)
                .font(.system(size: 100))
                .padding(.bottom, 20.0)
            Text(bearing != nil ? bearing!.toCardinalOrdinal() : "")
                .font(.largeTitle)
                .bold()
            Text(distance != nil ? distance!.convertToHumanReadable(settings: userSettings) : "")
                .font(.title)
            HStack {
                Text("Location accuracy:")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                Text("±\(userLocation.lastLocation?.horizontalAccuracy.convertToHumanReadable(settings: userSettings) ?? "Not available")")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            HStack {
                Text("Compass accuracy:")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                Text("±\(userLocation.lastHeading?.headingAccuracy.rounded(toPlaces: 2) ?? 360.0, specifier: "%.2f")°")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
        }
        .navigationTitle(destinationPlace?.name ?? "Loading...")
        .onAppear {
            userLocation.updateOrientation(newOrientation: self.orientation.convertToCLDeviceOrientation())
            switch destinationPlaceType {
            case "googleplace":
                geocoder.placeDetails(placeId: destinationPlaceId, callback: { (place: GooglePlacesPlace) -> Void in
                    let savedPlace = NavigablePlace(context: viewContext)
                    savedPlace.name = place.name
                    savedPlace.address = place.formattedAddress
                    savedPlace.latitude = place.coordinates.coordinate.latitude
                    savedPlace.longitude = place.coordinates.coordinate.longitude
                    savedPlace.timestamp = Date()
                    savedPlace.id = UUID()
                    do {
                        if userSettings.history {
                            try viewContext.save()
                        }
                    } catch {
                        let nsError = error as NSError
                        fatalError("Failed to save navigable place: \(nsError)")
                    }
                    destinationPlace = savedPlace
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
                    fatalError("Unable to load place from local storage")
                }
            case "coordinates":
                let savedPlace = NavigablePlace(context: viewContext)
                savedPlace.name = destinationPlaceId
                savedPlace.latitude = Double(destinationPlaceId.split(separator: ",").first!)!
                savedPlace.longitude = Double(destinationPlaceId.split(separator: ",").last!)!
                savedPlace.timestamp = Date()
                savedPlace.id = UUID()
                do {
                    if userSettings.history {
                        try viewContext.save()
                    }
                } catch {
                    let nsError = error as NSError
                    fatalError("Failed to save navigable place: \(nsError)")
                }
                destinationPlace = savedPlace
            default:
                fatalError("Unknown place ID (\(destinationPlaceId)) passed to the OrienteerView")
            }
        }
        .onReceive(orientationChanged, perform: { _ in
            let newOrientation = UIDevice.current.orientation
            if newOrientation != UIDeviceOrientation.portraitUpsideDown {
                self.orientation = newOrientation
                userLocation.updateOrientation(newOrientation: newOrientation.convertToCLDeviceOrientation())
            }
        })
    }
}

struct OrienteerView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerView(destinationPlaceType: "history", destinationPlaceId: "F8CDB8FA-84C5-4CB1-9651-118D44D5BEE0", geocoder: Geocoder(), userLocation: UserLocation())
            .environmentObject(UserSettings())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
