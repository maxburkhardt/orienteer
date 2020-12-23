//
//  Geocoder.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import CoreLocation
import Foundation

class Geocoder {
    private var apiKey: String
    private var autocompleteSession: String
    private var errorHandler: (String) -> Void

    init(errorHandler: @escaping (String) -> Void = { message in print(message) }) {
        var secrets: NSDictionary?
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            secrets = NSDictionary(contentsOfFile: path)
        }
        if secrets == nil {
            fatalError("Couldn't load secrets from Secrets.plist")
        }
        apiKey = secrets!["APP_GOOGLE_KEY"] as! String
        autocompleteSession = UUID().uuidString
        self.errorHandler = errorHandler
    }

    private func makePlacesApiCall(urlBase: String, params: [String: String], callback: @escaping (Data) -> Void, requestCounter: SynchronizedCounter? = nil) {
        let authorizedParams = params.merging(["key": apiKey]) { _, new in new }
        var params = [String]()
        for (paramKey, paramValue) in authorizedParams {
            params.append("\(paramKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "k")=\(paramValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "v")")
        }
        let queryString = params.joined(separator: "&")
        guard let url = URL(string: "\(urlBase)?\(queryString)") else {
            errorHandler("Failed to construct Places query to \(urlBase)")
            return
        }
        var request = URLRequest(url: url)
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "x-ios-bundle-identifier")
        let task = URLSession.shared.dataTask(with: request) { result in
            requestCounter?.decrement()
            switch result {
            case let .success((_, data)):
                callback(data)
            case let .failure(error):
                self.errorHandler(error.localizedDescription)
            }
        }
        requestCounter?.increment()
        task.resume()
    }

    func placesAutocomplete(search: String, userLocation: CLLocation?, callback: @escaping (PlacesAutocompleteResponse) -> Void, requestCounter: SynchronizedCounter) {
        var params = [
            "input": search,
            "sessiontoken": autocompleteSession,
        ]
        if let location = userLocation {
            params["location"] = "\(location.coordinate.latitude.rounded(toPlaces: 1)),\(location.coordinate.longitude.rounded(toPlaces: 1))"
        }
        makePlacesApiCall(urlBase: "https://maps.googleapis.com/maps/api/place/autocomplete/json", params: params, callback: { (data: Data) -> Void in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let placesAutocompleteResponse: PlacesAutocompleteResponse = try! decoder.decode(PlacesAutocompleteResponse.self, from: data)
            callback(placesAutocompleteResponse)
        }, requestCounter: requestCounter)
    }

    func placeDetails(placeId: String, callback: @escaping (GooglePlacesPlace) -> Void) {
        let params = [
            "place_id": placeId,
            "sessiontoken": autocompleteSession,
            "fields": "name,geometry,formatted_address",
        ]
        // Rotate the autocomplete session once the place is looked up
        autocompleteSession = UUID().uuidString
        makePlacesApiCall(urlBase: "https://maps.googleapis.com/maps/api/place/details/json", params: params, callback: { (data: Data) -> Void in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let placeDetails: PlaceDetailsResponse = try! decoder.decode(PlaceDetailsResponse.self, from: data)
            if placeDetails.status == "OK" {
                callback(placeDetails.result)
            } else {
                print("Got error response from place lookup: \(placeDetails.result)")
            }
        })
    }
}
