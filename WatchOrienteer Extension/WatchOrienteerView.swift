//
//  WatchOrienteerView.swift
//  WatchOrienteer Extension
//
//  Created by Maximilian Burkhardt on 1/1/21.
//

import CoreLocation
import SwiftUI

struct WatchOrienteerView: View {
    @ObservedObject var userLocation: UserLocation
    var destinationName: String
    var destinationCoordinates: CLLocation
    var units: DistanceUnits

    var body: some View {
        let adjustmentMode = Binding<NavigationAdjustmentMode>(get: {
            if let speed = userLocation.lastSpeed {
                if speed > 4.0 {
                    return NavigationAdjustmentMode.course
                } else {
                    return NavigationAdjustmentMode.heading
                }
            } else {
                return NavigationAdjustmentMode.heading
            }
        }, set: { _ in do {} })
        VStack {
            OrienteerCompassView(
                bearing: userLocation.bearingTo(destination: destinationCoordinates),
                userLocation: userLocation,
                adjustmentMode: adjustmentMode
            )
            Text(userLocation.distanceTo(destination: destinationCoordinates).convertToHumanReadable(units: units))
                .font(.title)
                .fontWeight(.bold)
            HStack {
                Text(destinationName)
                    .font(.caption)
                if adjustmentMode.wrappedValue == .course {
                    Image(systemName: "bicycle")
                } else {
                    Image(systemName: "figure.walk")
                }
            }
        }
    }
}

struct WatchOrienteerView_Previews: PreviewProvider {
    static var previews: some View {
        WatchOrienteerView(
            userLocation: UserLocation(previewMode: true),
            destinationName: "Destination",
            destinationCoordinates: CLLocation(latitude: 37.0, longitude: -122.0),
            units: DistanceUnits.metric
        )
    }
}
