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
    @State private var destinationPlace: GooglePlacesPlace? = nil
    private var bearing: Double? {
        destinationPlace != nil ? userLocation.bearingTo(destination: destinationPlace!.coordinates) : nil
    }
    private var distance: Double? {
        destinationPlace != nil ? userLocation.distanceTo(destination: destinationPlace!.coordinates) : nil
    }
    
    var body: some View {
        VStack {
            Image(systemName: "location.north.line")
                .rotationEffect(bearing != nil ? Angle(degrees: bearing!) : .zero)
                .font(.system(size: 60))
                .padding(.bottom, 20.0)
            Text(bearing != nil ? "\(bearing!)" : "")
            Text(distance != nil ? "\(distance!) m" : "")
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
    }
}
