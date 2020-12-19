//
//  Location.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import Foundation
import CoreLocation

struct Location: Hashable, Codable {
    var id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
