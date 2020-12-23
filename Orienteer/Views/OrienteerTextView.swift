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
    var userSettings: UserSettings
    @EnvironmentObject var userLocation: UserLocation

    var body: some View {
        VStack {
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
    }
}

struct OrienteerTextView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerTextView(bearing: 0, distance: 0, userSettings: UserSettings()).environmentObject(UserLocation())
    }
}
