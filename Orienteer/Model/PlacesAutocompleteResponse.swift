//
//  PlacesAutocompleteResponse.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/20/20.
//

import Foundation

struct PlacesText: Decodable {
    let text: String
}

struct PlacesStructuredFormat: Decodable {
    let mainText: PlacesText
    // secondaryText is not populated for all places.
    let secondaryText: PlacesText?
}

struct PlacesAutocompletePrediction: Decodable {
    let placeId: String
    /// The full description, e.g. "Golden Gate Bridge, San Francisco, CA, USA".
    let text: PlacesText
    let structuredFormat: PlacesStructuredFormat?

    var mainText: String { structuredFormat?.mainText.text ?? text.text }
    var secondaryText: String? { structuredFormat?.secondaryText?.text }
}

struct PlacesAutocompleteSuggestion: Decodable {
    // Each suggestion is either a place or a query; only places are requested.
    let placePrediction: PlacesAutocompletePrediction?
}

/// The Autocomplete (New) response.
struct PlacesAutocompleteResponse: Decodable {
    // Omitted entirely when there are no suggestions.
    let suggestions: [PlacesAutocompleteSuggestion]?

    var predictions: [PlacesAutocompletePrediction] {
        suggestions?.compactMap(\.placePrediction) ?? []
    }
}

/// The error body Google APIs return with a non-2xx status.
struct GoogleAPIErrorResponse: Decodable {
    struct Details: Decodable {
        let code: Int?
        let message: String?
        let status: String?
    }

    let error: Details
}
