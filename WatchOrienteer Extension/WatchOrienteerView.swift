//
//  WatchOrienteerView.swift
//  WatchOrienteer Extension
//
//  Created by Maximilian Burkhardt on 1/1/21.
//

import CoreLocation
import SwiftUI

struct WatchOrienteerView: View {
    @EnvironmentObject var userLocation: UserLocation
    var destinationName: String
    var destinationCoordinates: CLLocation
    var units: DistanceUnits
    @State var adjustmentMode = NavigationAdjustmentMode.heading

    var body: some View {
        VStack {
            OrienteerCompassView(
                bearing: userLocation.bearingTo(destination: destinationCoordinates),
                userLocation: userLocation,
                adjustmentMode: $adjustmentMode
            )
            Text(userLocation.distanceTo(destination: destinationCoordinates).convertToHumanReadable(units: units))
                .font(.title)
                .fontWeight(.bold)
            Text(destinationName)
                .font(.caption)
        }
    }
}

struct WatchOrienteerView_Previews: PreviewProvider {
    static var previews: some View {
        WatchOrienteerView(
            destinationName: "Destination",
            destinationCoordinates: CLLocation(latitude: 37.0, longitude: -122.0),
            units: DistanceUnits.metric
        )
        .environmentObject(UserLocation(previewMode: true))
    }
}
