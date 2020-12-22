//
//  OrienteerView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/20/20.
//

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
    private var bearing: DegreesFromNorth? {
        destinationPlace != nil ? userLocation.bearingTo(destination: destinationPlace!.coordinates) : nil
    }

    private var distance: CLLocationDistance? {
        destinationPlace != nil ? userLocation.distanceTo(destination: destinationPlace!.coordinates) : nil
    }

    var body: some View {
        VStack {
            Image(systemName: "location.north.line")
                .rotationEffect(bearing != nil ? Angle(degrees: bearing! - (userLocation.lastHeading?.trueHeading ?? 0)) : .zero)
                .font(.system(size: 60))
                .padding(.bottom, 20.0)
            Text(bearing != nil ? bearing!.toCardinalOrdinal() : "")
            Text(distance != nil ? distance!.convertToHumanReadable(settings: userSettings) : "")
        }
        .navigationTitle(destinationPlace?.name ?? "Loading...")
        .onAppear {
            switch destinationPlaceType {
            case "googleplace":
                geocoder.placeDetails(placeId: destinationPlaceId, callback: { (place: GooglePlacesPlace) -> Void in
                    let savedPlace = NavigablePlace(context: viewContext)
                    savedPlace.name = place.name
                    savedPlace.address = place.formattedAddress
                    savedPlace.latitude = place.coordinates.coordinate.latitude
                    savedPlace.longitude = place.coordinates.coordinate.longitude
                    savedPlace.timestamp = Date()
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Failed to save navigable place: \(nsError)")
                    }
                    destinationPlace = savedPlace
                })
            case "coordinates":
                // TODO:
                // destinationPlace = NavigablePlace(id: destinationPlaceId, name: "Entered Coordinates", address: nil, coordinates: <#T##CLLocation#>)
                break
            default:
                fatalError("Unknown place ID (\(destinationPlaceId)) passed to the OrienteerView")
            }
        }
    }
}

struct OrienteerView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerView(destinationPlaceType: "googleplace", destinationPlaceId: "ChIJIQBpAG2ahYAR_6128GcTUEo", geocoder: Geocoder(), userLocation: UserLocation())
            .environmentObject(UserSettings())
    }
}
