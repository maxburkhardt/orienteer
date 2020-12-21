//
//  OrienteerApp.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import SwiftUI

@main
struct OrienteerApp: App {
    @StateObject var userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            SearchView().environmentObject(userSettings)
        }
    }
}
