//
//  OrienteerCompassView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/22/20.
//

import SwiftUI

struct OrienteerCompassView: View {
    var bearing: Double?
    @ObservedObject var userLocation: UserLocation
    @Binding var adjustmentMode: NavigationAdjustmentMode
    @EnvironmentObject var userSettings: UserSettings

    // Must be an arrow that points straight up when unrotated: the angles below are measured from the top of the screen.
    private let arrowSymbol = "location.north.circle"

    private func isHeadingUsable() -> Bool {
        guard let heading = userLocation.lastHeading else { return false }
        return heading.trueHeading >= 0 && heading.headingAccuracy >= 0 && heading.headingAccuracy <= 30
    }

    private func isCourseUsable() -> Bool {
        guard let course = userLocation.lastCourse else { return false }
        return course.course >= 0 && course.accuracy >= 0 && course.accuracy <= 45
    }

    /// How far to rotate the arrow from straight up, or nil if the data this mode relies on isn't usable.
    private func arrowAngle(for mode: NavigationAdjustmentMode) -> Angle? {
        guard let bearing else { return nil }
        switch mode {
        case .heading:
            guard isHeadingUsable(), let heading = userLocation.lastHeading else { return nil }
            return .degrees(bearing - heading.trueHeading)
        case .course:
            guard isCourseUsable(), let course = userLocation.lastCourse else { return nil }
            return .degrees(bearing - course.course)
        case .unadjusted:
            return .degrees(bearing)
        }
    }

    private func unavailableMessage(for mode: NavigationAdjustmentMode) -> String {
        if bearing == nil {
            return "Waiting for your location"
        }
        switch mode {
        case .heading: return "Heading information unavailable"
        case .course: return "Course information unavailable"
        case .unadjusted: return ""
        }
    }

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
                    .disabled(userSettings.speedAdjustment)
                    .padding(.horizontal, 10.0)
                    AdjustmentHelpView().padding(.trailing, 10.0)
                }.frame(minWidth: nil, idealWidth: nil, maxWidth: 500.0, minHeight: nil, idealHeight: nil, maxHeight: nil, alignment: .center)
                if let angle = arrowAngle(for: adjustmentMode) {
                    Image(systemName: arrowSymbol)
                        .rotationEffect(angle)
                        .font(.system(size: 200))
                    // Placeholder to prevent elements from moving around
                    Text("")
                        .font(.caption)
                } else {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 200))
                    Text(unavailableMessage(for: adjustmentMode))
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                }
            }
            // Headings must be measured from the top of the screen as drawn, which is not always the top of the device.
            .background(InterfaceOrientationReader { orientation in
                if let headingOrientation = orientation.headingOrientation {
                    userLocation.updateOrientation(newOrientation: headingOrientation)
                }
            })
        #else
            if let angle = arrowAngle(for: adjustmentMode) {
                Image(systemName: arrowSymbol)
                    .rotationEffect(angle)
                    .font(.system(size: 72))
            } else {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 72))
            }
        #endif
    }
}

struct OrienteerCompassView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerCompassView(bearing: 0, userLocation: UserLocation(), adjustmentMode: Binding<NavigationAdjustmentMode>(get: { NavigationAdjustmentMode.heading }, set: { _ in do {} })).environmentObject(UserSettings())
    }
}
