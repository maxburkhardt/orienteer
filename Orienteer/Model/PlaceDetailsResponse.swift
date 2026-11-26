//
//  PlaceDetailsResponse.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/18/20.
//

import CoreLocation
import Foundation

/// A latitude/longitude pair as Places API (New) returns it.
struct GooglePlacesLatLng: Decodable {
    let latitude: Double
    let longitude: Double
}

/// The Place Details (New) response for the field mask `formattedAddress,location`.
struct PlaceDetailsResponse: Decodable {
    let formattedAddress: String?
    let location: GooglePlacesLatLng
}

/// A place to navigate to, looked up from Google Places.
struct GooglePlacesPlace {
    let name: String
    let formattedAddress: String?
    let coordinates: CLLocation
}
