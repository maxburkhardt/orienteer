//
//  AdjustmentHelpView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 1/18/21.
//

import SwiftUI

struct AdjustmentHelpView: View {
    @State private var showingAdjustmentHelp = false

    var body: some View {
        Button(action: { showingAdjustmentHelp = true }) {
            Image(systemName: "questionmark.circle")
        }
        .sheet(isPresented: $showingAdjustmentHelp, content: {
            VStack(alignment: .leading) {
                Text("About adjustments")
                    .font(.title)
                    .bold()
                    .padding(10.0)
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Orienteer supports three different direction calculation systems, and allows you to select between them for maximum accuracy depending on your type of activity.")
                            .padding(10.0)
                        Image(systemName: "figure.walk")
                            .padding(.horizontal, 10.0)
                        Text("In Walking mode, Orienteer uses your device's magnetometer to determine the orientation of the device. This works well at low speeds but is often inaccurate when traveling quickly.")
                            .padding(10.0)
                        Image(systemName: "bicycle")
                            .padding(.horizontal, 10.0)
                        Text("In Vehicle mode, Orienteer uses your device's GPS to determine the direction of travel, and adjusts its pointer based on that. This is most accurate when traveling at greater-than-walking speeds, but also introduces a small amount of directional lag as you turn.")
                            .padding(10.0)
                        Image(systemName: "location.north.line")
                            .padding(.horizontal, 10.0)
                        Text("In North mode, Orienteer assumes that the device is pointed due north, and will point in the direction of your bearing to the destination. This mode is most useful if you are using an external compass to determine your heading.")
                            .padding(10.0)
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAdjustmentHelp = false }) {
                        Text("OK")
                    }
                    .padding(.vertical, 10.0)
                    Spacer()
                }
            }
        })
    }
}

struct AdjustmentHelpView_Previews: PreviewProvider {
    static var previews: some View {
        AdjustmentHelpView()
    }
}
