//
//  OrienteerCompassView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/22/20.
//

import SwiftUI

enum NavigationAdjustmentMode {
    case heading
    case course
    case unadjusted
}

struct OrienteerCompassView: View {
    var bearing: Double?
    @ObservedObject var userLocation: UserLocation
    @EnvironmentObject var userSettings: UserSettings
    @State private var orientationAdjustment = 0.0
    @State private var orientationIsUnknown = false
    @State private var adjustmentMode = NavigationAdjustmentMode.heading

    private func computeHeadingAngle() -> Angle {
        guard let bearingValue = bearing else { return .zero }
        return Angle(degrees: bearingValue - (userLocation.lastHeading?.trueHeading ?? 0) + orientationAdjustment)
    }

    private func isHeadingUsable() -> Bool {
        guard let headingAccuracy = userLocation.lastHeading?.headingAccuracy else { return false }
        if headingAccuracy >= 0.0 && headingAccuracy <= 30 {
            return true
        } else {
            return false
        }
    }

    private func computeCourseAngle() -> Angle {
        guard let bearingValue = bearing else { return .zero }
        return Angle(degrees: bearingValue - (userLocation.lastCourse?.course ?? 0))
    }

    private func isCourseUsable() -> Bool {
        guard let courseAccuracy = userLocation.lastCourse?.accuracy else { return false }
        if courseAccuracy >= 0 && courseAccuracy <= 30 {
            return true
        } else {
            return false
        }
    }

    private func computeBearingAngle() -> Angle {
        guard let bearingValue = bearing else { return .zero }
        return Angle(degrees: bearingValue)
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
                HStack {
                    Picker("Adjustment Mode", selection: $adjustmentMode) {
                        Image(systemName: "figure.walk").tag(NavigationAdjustmentMode.heading)
                        Image(systemName: "bicycle").tag(NavigationAdjustmentMode.course)
                        Image(systemName: "location.north.line").tag(NavigationAdjustmentMode.unadjusted)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 10.0)
                    AdjustmentHelpView().padding(.trailing, 10.0)
                }
                if adjustmentMode == .heading {
                    if orientationIsUnknown && sizeClass == .compact {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 200))
                        Text("Device orientation unknown")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    } else if !isHeadingUsable() {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 200))
                        Text("Heading information unavailable")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    } else {
                        Image(systemName: "location.circle")
                            .rotationEffect(computeHeadingAngle())
                            .font(.system(size: 200))
                    }
                } else if adjustmentMode == .course {
                    if !isCourseUsable() {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 200))
                        Text("Course information unavailable")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                    } else {
                        Image(systemName: "location.circle")
                            .rotationEffect(computeCourseAngle())
                            .font(.system(size: 200))
                    }
                } else if adjustmentMode == .unadjusted {
                    Image(systemName: "location.circle")
                        .rotationEffect(computeBearingAngle())
                        .font(.system(size: 200))
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
        OrienteerCompassView(bearing: 0, userLocation: UserLocation()).environmentObject(UserSettings())
    }
}
