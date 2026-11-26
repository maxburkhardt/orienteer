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
        let adjustmentMode = userLocation.getAdjustmentBinding()
        VStack {
            OrienteerCompassView(
                bearing: userLocation.bearingTo(destination: destinationCoordinates),
                userLocation: userLocation,
                adjustmentMode: adjustmentMode
            )
            Text(userLocation.distanceTo(destination: destinationCoordinates)?.convertToHumanReadable(units: units) ?? "Locating…")
                .font(.title)
                .fontWeight(.bold)
                .monospacedDigit()
            HStack {
                Text(destinationName)
                    .font(.caption)
                    .lineLimit(2)
                Image(systemName: adjustmentMode.wrappedValue == .course ? "bicycle" : "figure.walk")
                    .contentTransition(.symbolEffect(.replace))
                    .animation(.default, value: adjustmentMode.wrappedValue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        WatchOrienteerView(
            userLocation: UserLocation(previewMode: true),
            destinationName: "Destination",
            destinationCoordinates: CLLocation(latitude: 37.0, longitude: -122.0),
            units: DistanceUnits.metric
        )
    }
}
