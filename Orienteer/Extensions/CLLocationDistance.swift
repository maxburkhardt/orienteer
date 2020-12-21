//
//  CLLocationDistance.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/21/20.
//

import CoreLocation
import Foundation

extension CLLocationDistance {
    func convertToHumanReadable(settings: UserSettings) -> String {
        switch settings.units {
        case DistanceUnits.imperial:
            if self < 1609 {
                return "\((self * 3.28084).rounded(toPlaces: 2)) feet"
            } else {
                return "\((self * 0.000621371).rounded(toPlaces: 2)) miles"
            }
        default:
            if self < 1000 {
                return "\(rounded(toPlaces: 2)) m"
            } else {
                return "\((self / 1000).rounded(toPlaces: 2)) km"
            }
        }
    }
}
