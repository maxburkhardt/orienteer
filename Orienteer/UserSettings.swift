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
    @Published var units = DistanceUnits.metric {
        didSet {
            userDefaults.set(units.rawValue, forKey: UNITS_STORAGE_KEY)
        }
    }

    init() {
        userDefaults = UserDefaults()
        if let savedUnits = userDefaults.value(forKey: UNITS_STORAGE_KEY) as? String {
            units = DistanceUnits(rawValue: savedUnits) ?? DistanceUnits.metric
        }
    }
}
