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
    @State private var orientationAdjustment = 0.0

    private func computeCompassAngle() -> Angle {
        guard let bearingValue = bearing else { return .zero }
        return Angle(degrees: bearingValue - (userLocation.lastHeading?.trueHeading ?? 0) + orientationAdjustment)
    }

    #if os(iOS)
        private let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()

        private func updateOrientationAdjustment(newOrientation: UIDeviceOrientation) {
            if newOrientation == .portrait {
                orientationAdjustment = 0.0
            } else if newOrientation == .landscapeLeft {
                orientationAdjustment = -90.0
            } else if newOrientation == .landscapeRight {
                orientationAdjustment = 90.0
            }
        }
    #endif

    var body: some View {
        #if os(iOS)
            VStack {
                Image(systemName: "location.circle")
                    .rotationEffect(computeCompassAngle())
                    .font(.system(size: 200))
                    .padding(.bottom, 20.0)
                if let heading = userLocation.lastHeading {
                    Text("heading: \(heading.trueHeading)")
                    Text("orientation: \(userLocation.getOrientation().rawValue)")
                    Text("adjustment: \(orientationAdjustment)")
                }
            }
            .onAppear {
                updateOrientationAdjustment(newOrientation: UIDevice.current.orientation)
            }
            .onReceive(orientationChanged, perform: { _ in
                updateOrientationAdjustment(newOrientation: UIDevice.current.orientation)
            })
        #else
            Image(systemName: "location.circle")
                .rotationEffect(bearing != nil ? Angle(degrees: bearing! - (userLocation.lastHeading?.trueHeading ?? 0)) : .zero)
                .font(.system(size: 72))
                .padding(.bottom, 0.0)
        #endif
    }
}

struct OrienteerCompassView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerCompassView(bearing: 0).environmentObject(UserLocation())
    }
}
