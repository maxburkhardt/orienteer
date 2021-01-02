//
//  OrienteerCompassView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/22/20.
//

import SwiftUI

// "large" is for phones/tablets
// "small" is for watches
enum CompassScale {
    case large
    case small
}

struct OrienteerCompassView: View {
    var bearing: Double?
    var scale: CompassScale
    @EnvironmentObject var userLocation: UserLocation

    var body: some View {
        Image(systemName: "location.circle")
            .rotationEffect(bearing != nil ? Angle(degrees: bearing! - (userLocation.lastHeading?.trueHeading ?? 0)) : .zero)
            .font(.system(size: scale == .large ? 200 : 72))
            .padding(.bottom, scale == .large ? 20.0 : 0.0)
    }
}

struct OrienteerCompassView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerCompassView(bearing: 0, scale: .large).environmentObject(UserLocation())
    }
}
