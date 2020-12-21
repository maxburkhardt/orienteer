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
        VStack {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 5.0)
            HStack {
                Text("Distance Units")
                Spacer()
            }
            Picker("Distance Units", selection: $userSettings.units) {
                Text("Metric").tag(DistanceUnits.metric)
                Text("Imperial").tag(DistanceUnits.imperial)
            }
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
            Button(action: { onDismiss() }, label: {
                Text("Done")
            })
        }
        .padding(10.0)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onDismiss: { do {} }).environmentObject(UserSettings())
    }
}
