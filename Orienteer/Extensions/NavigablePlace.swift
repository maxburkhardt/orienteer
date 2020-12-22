//
//  NavigablePlace.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/22/20.
//

import CoreLocation
import Foundation

extension NavigablePlace {
    var coordinates: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}
