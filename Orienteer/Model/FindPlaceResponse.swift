//
//  FindPlaceResponse.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/18/20.
//

import Foundation

struct GooglePlacesLocation: Decodable {
    let lat: Decimal
    let lng: Decimal
}

struct GooglePlacesGeometry: Decodable {
    let location: GooglePlacesLocation
}

struct GooglePlacesCandidatePlace: Decodable {
    let geometry: GooglePlacesGeometry
    let name: String
    let formattedAddress: String
}

struct FindPlaceResponse: Decodable {
    let candidates: Array<GooglePlacesCandidatePlace>
}
