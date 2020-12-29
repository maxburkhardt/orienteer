//
//  UserLocation.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/16/20.
//

import Combine
import CoreLocation
import Foundation

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

    // Returns distance to a location in meters
    func distanceTo(destination: CLLocation) -> CLLocationDistance {
        return lastLocation?.distance(from: destination) ?? 0
    }

    // Returns a bearing to a destination in degrees from true north
    func bearingTo(destination: CLLocation) -> DegreesFromNorth {
        if lastLocation == nil {
            return 0
        }
        let dest = (destination.coordinate.latitude, destination.coordinate.longitude)
        let src = (lastLocation!.coordinate.latitude, lastLocation!.coordinate.longitude)
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

    let objectWillChange = PassthroughSubject<Void, Never>()
}

extension UserLocation: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if !previewMode {
            locationStatus = status
        } else {
            locationStatus = CLAuthorizationStatus.authorizedWhenInUse
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
    }

    func locationManager(_: CLLocationManager, didUpdateHeading heading: CLHeading) {
        lastHeading = heading
    }
}
