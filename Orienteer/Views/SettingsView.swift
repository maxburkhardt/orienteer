//
//  SettingsView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/21/20.
//

import SwiftUI

struct SettingsView: View {
    var onDismiss: () -> Void
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        VStack(alignment: .leading) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical, 10.0)
            Group {
                HStack {
                    Text("Distance Units")
                    Spacer()
                }
                Picker("Distance Units", selection: $userSettings.units) {
                    Text("Metric").tag(DistanceUnits.metric)
                    Text("Imperial").tag(DistanceUnits.imperial)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom, 10.0)
            }
            Group {
                Toggle(isOn: $userSettings.disableScreenDim) {
                    Text("Keep screen on")
                }
                Text("Orienteer can keep your device's screen on while in the navigation view.")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            Group {
                Toggle(isOn: $userSettings.history) {
                    Text("Save history")
                }
                Text("If saving is disabled, destinations will still show in the History view while the app is open, but will not be permanently saved. Without location history, Orienteer will be more reliant on network access to load destination data.")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            Group {
                Toggle(isOn: $userSettings.locationSearch) {
                    Text("Location-based search")
                }
                Text("By sharing your approximate location with Google, Orienteer can improve the relevance of search results.")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            Group {
                Toggle(isOn: $userSettings.speedAdjustment) {
                    Text("Speed-based mode adjust")
                }
                Text("Orienteer can automatically select heading adjustment modes based on what is most likely to be accurate for your current speed.")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            Group {
                Toggle(isOn: $userSettings.debugMode) {
                    Text("Detailed information")
                }
                Text("Enable additional data display that can help resolve internal magnetometer issues.")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: { onDismiss() }, label: {
                    Text("Done")
                })
                Spacer()
            }
        }
        .padding(10.0)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onDismiss: { do {} }).environmentObject(UserSettings())
    }
}
