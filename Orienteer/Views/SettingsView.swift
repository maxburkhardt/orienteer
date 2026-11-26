//
//  SettingsView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/21/20.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Distance Units", selection: $userSettings.units) {
                        Text("Metric").tag(DistanceUnits.metric)
                        Text("Imperial").tag(DistanceUnits.imperial)
                    }
                }
                Section {
                    Toggle("Keep Screen On", isOn: $userSettings.disableScreenDim)
                } footer: {
                    Text("Orienteer can keep your device's screen on while in the navigation view.")
                }
                Section {
                    Toggle("Save History", isOn: $userSettings.history)
                } footer: {
                    Text("If saving is disabled, destinations will still show in the History view while the app is open, but will not be permanently saved. Without location history, Orienteer will be more reliant on network access to load destination data.")
                }
                Section {
                    Toggle("Location-Based Search", isOn: $userSettings.locationSearch)
                } footer: {
                    Text("By sharing your approximate location with Google, Orienteer can improve the relevance of search results.")
                }
                Section {
                    Toggle("Speed-Based Mode Adjust", isOn: $userSettings.speedAdjustment)
                } footer: {
                    Text("Orienteer can automatically select heading adjustment modes based on what is most likely to be accurate for your current speed.")
                }
                Section {
                    Toggle("Detailed Information", isOn: $userSettings.debugMode)
                } footer: {
                    Text("Enable additional data display that can help resolve internal magnetometer issues.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SheetCloseButton()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserSettings())
}
