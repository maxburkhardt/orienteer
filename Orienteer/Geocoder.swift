//
//  Geocoder.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import CoreLocation
import Foundation

class Geocoder {
    private var errorHandlerStack: [(String) -> Void]
    private var apiKey: String
    private var autocompleteSession: String
    var errorHandler: (String) -> Void {
        errorHandlerStack.first!
    }

    init() {
        var secrets: NSDictionary?
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            secrets = NSDictionary(contentsOfFile: path)
        }
        if secrets == nil {
            fatalError("Couldn't load secrets from Secrets.plist")
        }
        apiKey = secrets!["APP_GOOGLE_KEY"] as! String
        autocompleteSession = UUID().uuidString
        // Initialize the error handler stack with a basic "print" handler
        errorHandlerStack = [{ message in print(message) }]
    }

    /// Sends a Places API (New) request and decodes the response. The callback and any error are delivered on the main queue.
    private func makePlacesApiCall<T: Decodable>(url: URL, method: String = "GET", body: [String: Any]? = nil, fieldMask: String, callback: @escaping (T) -> Void, requestCounter: SynchronizedCounter? = nil) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(fieldMask, forHTTPHeaderField: "X-Goog-FieldMask")
        // Lets a key restricted to iOS apps accept the request.
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        let task = URLSession.shared.dataTask(with: request) { result in
            requestCounter?.decrement()
            DispatchQueue.main.async {
                switch result {
                case let .success((response, data)):
                    if let status = (response as? HTTPURLResponse)?.statusCode, !(200 ..< 300).contains(status) {
                        let apiError = try? JSONDecoder().decode(GoogleAPIErrorResponse.self, from: data)
                        self.errorHandler("Places API error (\(status)): \(apiError?.error.message ?? "no details")")
                        return
                    }
                    do {
                        callback(try JSONDecoder().decode(T.self, from: data))
                    } catch {
                        self.errorHandler("Places API decode error: \(error.localizedDescription)")
                    }
                case let .failure(error):
                    self.errorHandler(error.localizedDescription)
                }
            }
        }
        requestCounter?.increment()
        task.resume()
    }

    func placesAutocomplete(search: String, userLocation: CLLocation?, callback: @escaping (PlacesAutocompleteResponse) -> Void, requestCounter: SynchronizedCounter, userSettings: UserSettings) {
        var body: [String: Any] = [
            "input": search,
            "sessionToken": autocompleteSession,
        ]
        if userSettings.locationSearch, let location = userLocation {
            // Only an approximate location is shared: rounded to about 10 km.
            body["locationBias"] = [
                "circle": [
                    "center": [
                        "latitude": location.coordinate.latitude.rounded(toPlaces: 1),
                        "longitude": location.coordinate.longitude.rounded(toPlaces: 1),
                    ],
                    "radius": 50000.0,
                ],
            ]
        }
        makePlacesApiCall(
            url: URL(string: "https://places.googleapis.com/v1/places:autocomplete")!,
            method: "POST",
            body: body,
            fieldMask: "suggestions.placePrediction.placeId,suggestions.placePrediction.text.text,suggestions.placePrediction.structuredFormat",
            callback: callback,
            requestCounter: requestCounter
        )
    }

    /// Looks up a place chosen from autocomplete. The name comes from the autocomplete result rather than the details
    /// request: asking for the name would bill the session at a much higher rate than address and location alone.
    func placeDetails(placeId: String, name: String, callback: @escaping (GooglePlacesPlace) -> Void) {
        var components = URLComponents(string: "https://places.googleapis.com/v1/places/")!
        components.path += placeId
        components.queryItems = [URLQueryItem(name: "sessionToken", value: autocompleteSession)]
        // A details request ends the autocomplete session, so start a new one for the next search.
        autocompleteSession = UUID().uuidString
        guard let url = components.url else {
            errorHandler("Failed to construct Places query for \(placeId)")
            return
        }
        makePlacesApiCall(url: url, fieldMask: "formattedAddress,location", callback: { (response: PlaceDetailsResponse) in
            callback(GooglePlacesPlace(
                name: name,
                formattedAddress: response.formattedAddress,
                coordinates: CLLocation(latitude: response.location.latitude, longitude: response.location.longitude)
            ))
        })
    }

    func pushErrorHandler(handler: @escaping (String) -> Void) {
        errorHandlerStack.insert(handler, at: 0)
    }

    func popErrorHandler() {
        guard errorHandlerStack.count > 1 else {
            print("Refusing to pop last error handler.")
            return
        }
        errorHandlerStack.removeFirst()
    }
}
