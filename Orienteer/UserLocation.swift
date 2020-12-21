//
//  UserLocation.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/16/20.
//

import Foundation
import CoreLocation
import Combine

class UserLocation: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
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
    
    // Returns distance to a location in meters
    func distanceTo(destination: CLLocation) -> CLLocationDistance {
        return self.lastLocation?.distance(from: destination) ?? 0
    }
    
    // Returns a bearing to a destination in degrees from true north
    func bearingTo(destination: CLLocation) -> Double {
        if self.lastLocation == nil {
            return 0
        }
        let x = cos(destination.coordinate.latitude) * sin(destination.coordinate.longitude - self.lastLocation!.coordinate.longitude)
        let y = cos(self.lastLocation!.coordinate.latitude) * sin(destination.coordinate.latitude) -
            sin(self.lastLocation!.coordinate.latitude) * cos(destination.coordinate.latitude) * cos(destination.coordinate.longitude -
                                                                                                        self.lastLocation!.coordinate.longitude)
        return atan2(x, y) * 180.0 / .pi
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
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
    }
}
