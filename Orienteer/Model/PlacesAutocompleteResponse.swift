//
//  PlacesAutocompleteResponse.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/20/20.
//

import Foundation

struct PlacesAutocompleteStructuredFormatting: Codable {
    let mainText: String
    let secondaryText: String
}

struct PlacesAutocompletePrediction: Codable, Identifiable {
    let description: String
    let placeId: String
    var id: String { "googleplace:\(placeId)" }
    let structuredFormatting: PlacesAutocompleteStructuredFormatting
}

struct PlacesAutocompleteResponse: Codable {
    let predictions: Array<PlacesAutocompletePrediction>
}
