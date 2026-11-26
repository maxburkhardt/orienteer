//
//  SettingsView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/21/20.
//

import SwiftUI

/// The home screen icons to choose from: the current design, and the original one.
private enum AppIconChoice: String, CaseIterable, Identifiable {
    case standard
    case classic

    var id: Self { self }

    /// The icon set's name in the asset catalog, or nil for the primary icon. Alternate sets must also be listed in
    /// the app target's ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES build setting to be included in the app.
    var alternateIconName: String? {
        switch self {
        case .standard: return nil
        case .classic: return "AppIcon-Classic"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .standard: return "Default"
        case .classic: return "Classic"
        }
    }

    /// A small copy of the icon for display, since app icon sets can't be loaded as images.
    var previewImage: String {
        switch self {
        case .standard: return "AppIconPreview"
        case .classic: return "AppIconPreview-Classic"
        }
    }

    init(alternateIconName: String?) {
        self = Self.allCases.first { $0.alternateIconName == alternateIconName } ?? .standard
    }
}

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    /// The system owns which icon is in use; this mirrors it so the picker can update straight away.
    @State private var appIcon = AppIconChoice.standard

    private func select(_ choice: AppIconChoice) {
        guard choice != appIcon else { return }
        let previous = appIcon
        appIcon = choice
        Task {
            do {
                try await UIApplication.shared.setAlternateIconName(choice.alternateIconName)
            } catch {
                appIcon = previous
            }
        }
    }

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
                if UIApplication.shared.supportsAlternateIcons {
                    Section {
                        Picker("App Icon", selection: Binding(get: { appIcon }, set: select)) {
                            ForEach(AppIconChoice.allCases) { choice in
                                HStack(spacing: 12) {
                                    Image(choice.previewImage)
                                        .resizable()
                                        .frame(width: 44, height: 44)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .accessibilityHidden(true)
                                    Text(choice.title)
                                }
                                .tag(choice)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                }
            }
            .onAppear {
                appIcon = AppIconChoice(alternateIconName: UIApplication.shared.alternateIconName)
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
