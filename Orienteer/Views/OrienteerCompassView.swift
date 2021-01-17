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
    @State private var orientationIsUnknown = false

    private func computeCompassAngle() -> Angle {
        guard let bearingValue = bearing else { return .zero }
        return Angle(degrees: bearingValue - (userLocation.lastHeading?.trueHeading ?? 0) + orientationAdjustment)
    }

    #if os(iOS)
        @Environment(\.verticalSizeClass) private var sizeClass
        private let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()

        private func updateOrientationAdjustment(newOrientation: UIDeviceOrientation) {
            if newOrientation == .portrait {
                orientationIsUnknown = false
                orientationAdjustment = 0.0
            } else if newOrientation == .landscapeLeft {
                orientationIsUnknown = false
                orientationAdjustment = -90.0
            } else if newOrientation == .landscapeRight {
                orientationIsUnknown = false
                orientationAdjustment = 90.0
            } else if newOrientation == .unknown {
                orientationIsUnknown = true
            }
        }
    #endif

    var body: some View {
        #if os(iOS)
            VStack {
                if orientationIsUnknown && sizeClass == .compact {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 200))
                    Text("Device orientation unknown")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                } else {
                    Image(systemName: "location.circle")
                        .rotationEffect(computeCompassAngle())
                        .font(.system(size: 200))
                        .padding(.bottom, 20.0)
                }
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
