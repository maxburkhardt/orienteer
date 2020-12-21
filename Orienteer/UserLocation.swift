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

    override init() {
        super.init()
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
        let x = cos(destination.coordinate.latitude) * sin(destination.coordinate.longitude - lastLocation!.coordinate.longitude)
        let y = cos(lastLocation!.coordinate.latitude) * sin(destination.coordinate.latitude) -
            sin(lastLocation!.coordinate.latitude) * cos(destination.coordinate.latitude) * cos(destination.coordinate.longitude -
                lastLocation!.coordinate.longitude)
        let radiansBearing = atan2(x, y)
        let degreesBearing = radiansBearing * 180.0 / .pi
        let positiveDegreesBearing = (degreesBearing + 360.0).truncatingRemainder(dividingBy: 360.0)
        return positiveDegreesBearing
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }

        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    let objectWillChange = PassthroughSubject<Void, Never>()
}

extension UserLocation: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
    }

    func locationManager(_: CLLocationManager, didUpdateHeading heading: CLHeading) {
        lastHeading = heading
    }
}
