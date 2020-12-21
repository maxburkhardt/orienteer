//
//  FindPlaceResponse.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/18/20.
//

import Foundation
import CoreLocation

struct GooglePlacesLocation: Decodable {
    let lat: Double
    let lng: Double
}

struct GooglePlacesGeometry: Decodable {
    let location: GooglePlacesLocation
}

struct GooglePlacesPlace: Decodable {
    let geometry: GooglePlacesGeometry
    let name: String
    let formattedAddress: String
    var coordinates: CLLocation {
        CLLocation(latitude: geometry.location.lat, longitude: geometry.location.lng)
    }
}

struct FindPlaceResponse: Decodable {
    let candidates: Array<GooglePlacesPlace>
}

struct PlaceDetailsResponse: Decodable {
    let result: GooglePlacesPlace
    let status: String
}
