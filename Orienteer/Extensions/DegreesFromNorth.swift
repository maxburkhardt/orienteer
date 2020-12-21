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
    func toCardinalOrdinal() -> String {
        switch self {
        case 0 ..< 23:
            return "N"
        case 23 ..< 68:
            return "NE"
        case 68 ..< 113:
            return "E"
        case 113 ..< 157:
            return "SE"
        case 157 ..< 202:
            return "S"
        case 202 ..< 247:
            return "SW"
        case 247 ..< 292:
            return "W"
        case 292 ..< 337:
            return "NW"
        default:
            return "N"
        }
    }
}
