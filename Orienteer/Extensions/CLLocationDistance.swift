//
//  CLLocationDistance.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/21/20.
//

import CoreLocation
import Foundation

extension CLLocationDistance {
    func convertToHumanReadable(units: DistanceUnits) -> String {
        switch units {
        case .imperial:
            if self < 1609 {
                return "\((self * 3.28084).rounded(toPlaces: 1)) ft"
            } else {
                return "\((self * 0.000621371).rounded(toPlaces: 1)) mi"
            }
        default:
            if self < 1000 {
                return "\(rounded(toPlaces: 1)) m"
            } else {
                return "\((self / 1000).rounded(toPlaces: 1)) km"
            }
        }
    }
}
