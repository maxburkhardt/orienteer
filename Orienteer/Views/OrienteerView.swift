//
//  OrienteerView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/20/20.
//

import SwiftUI
import CoreLocation

struct OrienteerView: View {
    var destinationPlaceId: String
    var geocoder: Geocoder
    @ObservedObject var userLocation: UserLocation
    @EnvironmentObject var userSettings: UserSettings
    @State private var destinationPlace: GooglePlacesPlace? = nil
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
        .onAppear() {
            geocoder.placeDetails(placeId: destinationPlaceId, callback: {(place: GooglePlacesPlace) -> Void in
                destinationPlace = place
            })
        }
    }
}

struct OrienteerView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerView(destinationPlaceId: "ChIJIQBpAG2ahYAR_6128GcTUEo", geocoder: Geocoder(), userLocation: UserLocation())
            .environmentObject(UserSettings())
    }
}
