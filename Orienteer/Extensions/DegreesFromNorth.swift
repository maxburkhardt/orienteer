//
//  Heading.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/21/20.
//

import Foundation

typealias DegreesFromNorth = Double

extension DegreesFromNorth {
    // Transform a degrees-from-north value to a string, like "N", "SW", etc.
    // Each direction covers 45°, centered on its own angle (N is 337.5° up to 22.5°).
    func toCardinalOrdinal() -> String {
        guard isFinite else { return "N" }
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let normalized = (truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        return directions[Int((normalized + 22.5) / 45) % 8]
    }
}
