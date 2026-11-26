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

    // Must be an arrow that points straight up when unrotated: the angles below are measured from the top of the screen.
    private let arrowSymbol = "location.north.circle"

    /// The arrow's current rotation in degrees. Not limited to 0–360°, so animations can always take the short way round.
    @State private var displayedDegrees: Double = 0

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
        let angle = arrowAngle(for: adjustmentMode)
        #if os(iOS)
            VStack {
                arrow(angle: angle, size: 200)
                // Always present (even if empty) so the layout doesn't shift when the message appears.
                Text(angle == nil ? unavailableMessage(for: adjustmentMode) : "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            // Headings must be measured from the top of the screen as drawn, which is not always the top of the device.
            // From iOS 27, Core Location can measure from this view directly, which also handles which display it's on
            // (e.g. iPhone Duo); before that, tell it the device orientation that matches the interface.
            .background(InterfaceOrientationReader(
                onChange: { orientation in
                    if let headingOrientation = orientation.headingOrientation {
                        userLocation.updateOrientation(newOrientation: headingOrientation)
                    }
                },
                onWindowChange: { view, isInWindow in
                    if #available(iOS 27, *) {
                        if isInWindow {
                            userLocation.attachHeadingBody(view)
                        } else {
                            userLocation.detachHeadingBody(view)
                        }
                    }
                }
            ))
        #else
            arrow(angle: angle, size: 72)
        #endif
    }

    /// The arrow pointing at the destination, or a question mark when the direction isn't known.
    private func arrow(angle: Angle?, size: CGFloat) -> some View {
        Image(systemName: angle == nil ? "questionmark.circle" : arrowSymbol)
            .font(.system(size: size))
            .contentTransition(.symbolEffect(.replace))
            .animation(.default, value: angle == nil)
            .rotationEffect(angle == nil ? .zero : .degrees(displayedDegrees))
            .onChange(of: angle?.degrees, initial: true) { oldDegrees, newDegrees in
                guard let newDegrees else { return }
                if let oldDegrees, oldDegrees != newDegrees {
                    // Turn the short way round (e.g. 350° to 10° is +20°, not -340°), and ease between readings.
                    withAnimation(.smooth(duration: 0.3)) {
                        displayedDegrees += remainder(newDegrees - displayedDegrees, 360)
                    }
                } else {
                    // First reading, or the arrow is reappearing: point straight at it without spinning.
                    displayedDegrees = newDegrees
                }
            }
    }
}

struct OrienteerCompassView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerCompassView(bearing: 0, userLocation: UserLocation(), adjustmentMode: Binding<NavigationAdjustmentMode>(get: { NavigationAdjustmentMode.heading }, set: { _ in do {} })).environmentObject(UserSettings())
    }
}
