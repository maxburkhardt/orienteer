//
//  UserSettings.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/21/20.
//

import Foundation

enum DistanceUnits: String {
    case metric
    case imperial
}

class UserSettings: ObservableObject {
    private let userDefaults: UserDefaults
    private let UNITS_STORAGE_KEY = "units"
    private let HISTORY_STORAGE_KEY = "history"
    private let LOCATION_SEARCH_KEY = "locationsearch"

    @Published var units = DistanceUnits.metric {
        didSet {
            userDefaults.set(units.rawValue, forKey: UNITS_STORAGE_KEY)
        }
    }

    @Published var history = true {
        didSet {
            userDefaults.set(history, forKey: HISTORY_STORAGE_KEY)
        }
    }

    @Published var locationSearch = true {
        didSet {
            userDefaults.set(locationSearch, forKey: LOCATION_SEARCH_KEY)
        }
    }

    init() {
        userDefaults = UserDefaults()
        if let savedUnits = userDefaults.value(forKey: UNITS_STORAGE_KEY) as? String {
            units = DistanceUnits(rawValue: savedUnits) ?? DistanceUnits.metric
        }
        if let savedHistory = userDefaults.value(forKey: HISTORY_STORAGE_KEY) as? Bool {
            history = savedHistory
        }
        if let savedLocationSearch = userDefaults.value(forKey: LOCATION_SEARCH_KEY) as? Bool {
            locationSearch = savedLocationSearch
        }
    }
}
