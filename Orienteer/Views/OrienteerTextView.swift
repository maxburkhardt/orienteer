//
//  OrienteerTextView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/22/20.
//

import SwiftUI

struct OrienteerTextView: View {
    var bearing: Double?
    var distance: Double?
    @ObservedObject var userLocation: UserLocation
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        VStack {
            if let knownBearing = bearing {
                Text("\(knownBearing.toCardinalOrdinal())")
                    .font(.largeTitle)
                    .bold()
                if userSettings.debugMode {
                    Text("\(knownBearing, specifier: "%.1f")°")
                }
            } else {
                Text("Bearing unknown")
                    .font(.largeTitle)
                    .bold()
            }
            Text(distance != nil ? distance!.convertToHumanReadable(units: userSettings.units) : "")
                .font(.title)
            Text("Location accuracy: ±\(userLocation.lastLocation?.horizontalAccuracy.convertToHumanReadable(units: userSettings.units) ?? "Not available")")
                .font(.caption)
                .foregroundColor(Color.gray)
            if userSettings.debugMode {
                Text("Heading: \(userLocation.lastHeading?.trueHeading ?? 0.0, specifier: "%.1f")±\(userLocation.lastHeading?.headingAccuracy ?? 0.0, specifier: "%.1f")°")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                Text("Course: \(userLocation.lastCourse?.course ?? 0.0, specifier: "%.1f")°±\(userLocation.lastCourse?.accuracy ?? 0.0, specifier: "%.1f")°\n")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
        }
    }
}

struct OrienteerTextView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerTextView(bearing: 0, distance: 0, userLocation: UserLocation())
    }
}
