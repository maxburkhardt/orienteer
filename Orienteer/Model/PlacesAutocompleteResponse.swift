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

struct PlacesAutocompletePrediction: Codable, Identifiable {
    let description: String
    let placeId: String
    var id: String { "googleplace:\(placeId)" }
    let structuredFormatting: PlacesAutocompleteStructuredFormatting
}

struct PlacesAutocompleteResponse: Codable {
    let predictions: [PlacesAutocompletePrediction]
}
