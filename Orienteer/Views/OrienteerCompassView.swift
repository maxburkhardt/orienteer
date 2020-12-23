//
//  OrienteerCompassView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/22/20.
//

import SwiftUI

struct OrienteerCompassView: View {
    var bearing: Double?
    @EnvironmentObject var userLocation: UserLocation

    var body: some View {
        Image(systemName: "location.circle")
            .rotationEffect(bearing != nil ? Angle(degrees: bearing! - (userLocation.lastHeading?.trueHeading ?? 0)) : .zero)
            .font(.system(size: 200))
            .padding(.bottom, 20.0)
    }
}

struct OrienteerCompassView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerCompassView(bearing: 0).environmentObject(UserLocation())
    }
}
