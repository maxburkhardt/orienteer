//
//  PlacesAutocompleteResponse.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/20/20.
//

import Foundation

struct PlacesAutocompleteStructuredFormatting: Codable {
    let mainText: String
    // secondaryText does not appear to be populated for all places.
    let secondaryText: String?
}

struct PlacesAutocompletePrediction: Codable {
    let description: String
    let placeId: String
    let structuredFormatting: PlacesAutocompleteStructuredFormatting
}

struct PlacesAutocompleteResponse: Codable {
    let predictions: [PlacesAutocompletePrediction]
}
