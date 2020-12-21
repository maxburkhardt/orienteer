//
//  UserSettings.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/21/20.
//

import Foundation

enum DistanceUnits: String {
    case metric = "metric"
    case imperial = "imperial"
}

class UserSettings: ObservableObject {
    private let userDefaults: UserDefaults
    private let UNITS_STORAGE_KEY = "units"
    @Published var units = DistanceUnits.metric {
        didSet {
            self.userDefaults.set(units.rawValue, forKey: UNITS_STORAGE_KEY)
        }
    }
    
    init() {
        self.userDefaults = UserDefaults()
        if let savedUnits = self.userDefaults.value(forKey: UNITS_STORAGE_KEY) as? String {
            self.units = DistanceUnits(rawValue: savedUnits) ?? DistanceUnits.metric
        }
    }
}
