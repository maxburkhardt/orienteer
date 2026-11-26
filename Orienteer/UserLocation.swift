//
//  UserLocation.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/16/20.
//

import Combine
import CoreLocation
import Foundation
import SwiftUI

class UserLocation: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private var previewMode = false

    init(previewMode: Bool = false) {
        super.init()
        self.previewMode = previewMode
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastHeading: CLHeading? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastCourse: CourseInformation? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastSpeed: CLLocationSpeed? {
        willSet {
            objectWillChange.send()
        }
    }

    // Returns distance to a location in meters, or nil if the user's location isn't known yet
    func distanceTo(destination: CLLocation) -> CLLocationDistance? {
        return lastLocation?.distance(from: destination)
    }

    // Returns a bearing to a destination in degrees from true north, or nil if the user's location isn't known yet
    func bearingTo(destination: CLLocation) -> DegreesFromNorth? {
        guard let lastLocation else { return nil }
        let dest = (destination.coordinate.latitude, destination.coordinate.longitude)
        let src = (lastLocation.coordinate.latitude, lastLocation.coordinate.longitude)
        let x = cos(dest.0.toRadians()) * sin((dest.1 - src.1).toRadians())
        let y = cos(src.0.toRadians()) * sin(dest.0.toRadians()) - sin(src.0.toRadians()) * cos(dest.0.toRadians()) * cos((dest.1 - src.1).toRadians())
        let radiansBearing = atan2(x, y)
        let degreesBearing = radiansBearing.toDegrees()
        let positiveDegreesBearing = (degreesBearing + 360.0).truncatingRemainder(dividingBy: 360.0)
        return positiveDegreesBearing
    }

    func updateOrientation(newOrientation: CLDeviceOrientation) {
        locationManager.headingOrientation = newOrientation
    }

    func getOrientation() -> CLDeviceOrientation {
        return locationManager.headingOrientation
    }

    #if os(iOS)
        /// Measures headings from the top of `view` instead of from `headingOrientation`. Core Location follows the view
        /// as it rotates, and knows which display it's on, which an orientation alone can't express (e.g. iPhone Duo
        /// unfolded, whose display is turned 90° from the folded one).
        @available(iOS 27, *)
        func attachHeadingBody(_ view: UIView) {
            locationManager.headingBody = view
        }

        /// Goes back to measuring headings from `headingOrientation`, unless another view has since been attached.
        @available(iOS 27, *)
        func detachHeadingBody(_ view: UIView) {
            if locationManager.headingBody === view {
                locationManager.headingBody = nil
            }
        }
    #endif

    func getAdjustmentBinding() -> Binding<NavigationAdjustmentMode> {
        return Binding<NavigationAdjustmentMode>(get: {
            if let speed = self.lastSpeed {
                if speed > 4.0 {
                    return NavigationAdjustmentMode.course
                } else {
                    return NavigationAdjustmentMode.heading
                }
            } else {
                return NavigationAdjustmentMode.heading
            }
        }, set: { _ in do {} })
    }

    let objectWillChange = PassthroughSubject<Void, Never>()
}

extension UserLocation: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if !previewMode {
            locationStatus = manager.authorizationStatus
        } else {
            locationStatus = CLAuthorizationStatus.authorizedWhenInUse
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        lastCourse = CourseInformation(course: location.course, accuracy: location.courseAccuracy)
        lastSpeed = location.speed
    }

    func locationManager(_: CLLocationManager, didUpdateHeading heading: CLHeading) {
        lastHeading = heading
    }
}
