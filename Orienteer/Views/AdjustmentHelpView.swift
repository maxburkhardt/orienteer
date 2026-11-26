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
        Button("About Adjustments", systemImage: "questionmark.circle") {
            showingAdjustmentHelp = true
        }
        .labelStyle(.iconOnly)
        .sheet(isPresented: $showingAdjustmentHelp) {
            AdjustmentHelpSheet()
        }
    }
}

private struct AdjustmentHelpSheet: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Orienteer supports three different direction calculation systems, and allows you to select between them for maximum accuracy depending on your type of activity.")
                }
                Section {
                    mode(
                        systemImage: "figure.walk",
                        description: "In Walking mode, Orienteer uses your device's magnetometer to determine the orientation of the device. This works well at low speeds but is often inaccurate when traveling quickly."
                    )
                    mode(
                        systemImage: "bicycle",
                        description: "In Vehicle mode, Orienteer uses your device's GPS to determine the direction of travel, and adjusts its pointer based on that. This is most accurate when traveling at greater-than-walking speeds, but also introduces a small amount of directional lag as you turn."
                    )
                    mode(
                        systemImage: "location.north.line",
                        description: "In North mode, Orienteer assumes that the device is pointed due north, and will point in the direction of your bearing to the destination. This mode is most useful if you are using an external compass to determine your heading."
                    )
                }
            }
            .navigationTitle("About Adjustments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SheetCloseButton(title: "OK")
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func mode(systemImage: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text(description)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AdjustmentHelpView()
}

#Preview("Sheet") {
    AdjustmentHelpSheet()
}
