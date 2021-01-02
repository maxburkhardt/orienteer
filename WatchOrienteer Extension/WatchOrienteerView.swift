//
//  WatchOrienteerView.swift
//  WatchOrienteer Extension
//
//  Created by Maximilian Burkhardt on 1/1/21.
//

import SwiftUI

struct WatchOrienteerView: View {
    @EnvironmentObject var userLocation: UserLocation

    var body: some View {
        VStack {
            OrienteerCompassView(bearing: 30.0, scale: .small).environmentObject(userLocation)
        }
    }
}

struct WatchOrienteerView_Previews: PreviewProvider {
    static var previews: some View {
        WatchOrienteerView()
    }
}
