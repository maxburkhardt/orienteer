//
//  Geocoder.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import Foundation
import CoreLocation

enum GeocoderError : Error {
    case missingSecrets
}

class Geocoder {
    private var apiKey = ""
    
    init() {
        var secrets: NSDictionary?
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            secrets = NSDictionary(contentsOfFile: path)
        }
        if secrets == nil {
            apiKey = ""
        }
        #if targetEnvironment(simulator)
        apiKey = secrets!["SIMULATOR_GOOGLE_KEY"] as! String
        #else
        apiKey = secrets!["APP_GOOGLE_KEY"] as! String
        #endif
    }
    
    func reportError(message: String) {
        print(message);
    }
    
    func searchForPlace(search: String, location: CLLocation?) {
        let key = "key=\(self.apiKey)"
        let input = "input=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let inputType = "inputtype=textquery"
        let locationBias = location != nil ? "locationbias=point:\(location!.coordinate.latitude),\(location!.coordinate.longitude)" : ""
        let fields = "fields=name,geometry"
        let query = [key, input, inputType, locationBias, fields].joined(separator: "&")
        print("QUERY: \(query)")
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?\(query)") else {
            reportError(message: "Failed to construct Places query")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (result) in
            switch result {
            case .success((_, let data)):
                print(String(data: data, encoding: String.Encoding.utf8))
                break
            case .failure(let error):
                self.reportError(message: error.localizedDescription)
                break
            }
        }
        task.resume()
    }
}
