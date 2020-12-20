//
//  Geocoder.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import Foundation
import CoreLocation

class Geocoder {
    private var apiKey = ""
    
    init() {
        var secrets: NSDictionary?
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            secrets = NSDictionary(contentsOfFile: path)
        }
        if secrets == nil {
            fatalError("Couldn't load secrets from Secrets.plist")
        }
        #if targetEnvironment(simulator)
        apiKey = secrets!["SIMULATOR_GOOGLE_KEY"] as! String
        #else
        apiKey = secrets!["APP_GOOGLE_KEY"] as! String
        #endif
    }
    
    private func reportError(message: String) {
        print(message);
    }
    
    private func makePlacesApiCall(urlBase: String, params: Dictionary<String, String>, callback: @escaping (Data) -> Void) {
        let authorizedParams = params.merging(["key": apiKey]) { (_, new) in new }
        var params = Array<String>()
        for (paramKey, paramValue) in authorizedParams {
            params.append("\(paramKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "k")=\(paramValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "v")")
        }
        let queryString = params.joined(separator: "&")
        guard let url = URL(string: "\(urlBase)?\(queryString)") else {
            reportError(message: "Failed to construct Places query to \(urlBase)")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (result) in
            switch result {
            case .success((_, let data)):
                callback(data)
            case .failure(let error):
                self.reportError(message: error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func findPlaceFromText(search: String, userLocation: CLLocation, callback: @escaping (FindPlaceResponse) -> Void) {
        let params = [
            "input": search,
            "inputtype": "textquery",
            "locationBias": "point:\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)",
            "fields": "name,geometry,formatted_address",
        ]
        self.makePlacesApiCall(urlBase: "https://maps.googleapis.com/maps/api/place/findplacefromtext/json", params: params, callback: { (data: Data) -> Void in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let foundPlaceResponse: FindPlaceResponse = try! decoder.decode(FindPlaceResponse.self, from: data)
            callback(foundPlaceResponse)
        })
    }
    
    func placesAutocomplete(search: String, userLocation: CLLocation, session: String, callback: @escaping (PlacesAutocompleteResponse) -> Void) {
        let params = [
            "input": search,
            "location": "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)",
            "sessiontoken": session,
        ]
        self.makePlacesApiCall(urlBase: "https://maps.googleapis.com/maps/api/place/autocomplete/json", params: params, callback: { (data: Data) -> Void in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let placesAutocompleteResponse: PlacesAutocompleteResponse = try! decoder.decode(PlacesAutocompleteResponse.self, from: data)
            callback(placesAutocompleteResponse)
        })
    }
}
