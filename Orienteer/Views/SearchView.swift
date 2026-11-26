//
//  ContentView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import CoreData
import CoreLocation
import SwiftUI

struct SearchResultListEntry: Identifiable {
    let type: String
    let id: String
    let name: String
    let subtitle: String?
}

struct SearchView: View {
    @ObservedObject var userLocation: UserLocation
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var userSettings: UserSettings
    var geocoder: Geocoder
    @State private var searchInput = ""
    @State private var autocompleteResults = [PlacesAutocompletePrediction]()
    /// The search text that autocompleteResults were returned for.
    @State private var autocompleteQuery = ""
    @State private var settingsDisplayed = false
    @State private var historyDisplayed = false
    @State private var historySelectedEntryId: UUID? = nil
    @State private var historyNavigationActive = false
    @State private var appclipNavigationLink: String? = nil
    private var autocompleteRequestCount = SynchronizedCounter()
    private let coordinateRegex = try! NSRegularExpression(pattern: "^(-?[0-9]+\\.?[0-9]*)\\s*,\\s*(-?[0-9]+\\.?[0-9]*)$")

    /// `previewQuery` and `previewResults` are for previews: they start the view with a search already typed and its
    /// results loaded, without calling the Places API.
    init(userLocation: UserLocation, geocoder: Geocoder, previewQuery: String = "", previewResults: [PlacesAutocompletePrediction] = []) {
        self.userLocation = userLocation
        self.geocoder = geocoder
        _searchInput = State(initialValue: previewQuery)
        _autocompleteQuery = State(initialValue: previewQuery)
        _autocompleteResults = State(initialValue: previewResults)
    }

    private var searchResults: [SearchResultListEntry] {
        var results = [SearchResultListEntry]()
        if searchInput == "" {
            return results
        }
        let matchResult = coordinateRegex.matches(in: searchInput, range: NSMakeRange(0, searchInput.utf16.count))
        if !matchResult.isEmpty {
            let latitude = searchInput[Range(matchResult[0].range(at: 1), in: searchInput)!]
            let longitude = searchInput[Range(matchResult[0].range(at: 2), in: searchInput)!]
            results.append(SearchResultListEntry(type: "coordinates", id: "\(latitude),\(longitude)", name: searchInput, subtitle: "Manually entered"))
        }
        return results + autocompleteResults.map { result in
            SearchResultListEntry(type: "googleplace", id: result.placeId, name: result.structuredFormatting.mainText, subtitle: result.structuredFormatting.secondaryText)
        }
    }

    private var isAwaitingResults: Bool {
        !searchInput.isEmpty && autocompleteQuery != searchInput && autocompleteRequestCount.value != 0
    }

    /// On iOS 26 the system decides where the search field goes (with Liquid Glass); before that, keep it pinned
    /// under the title, since searching is the main thing this screen is for.
    private var searchFieldPlacement: SearchFieldPlacement {
        if #available(iOS 26, *) {
            return .automatic
        }
        return .navigationBarDrawer(displayMode: .always)
    }

    private func search(for query: String) {
        guard !query.isEmpty else {
            autocompleteResults = []
            autocompleteQuery = ""
            return
        }
        geocoder.placesAutocomplete(
            search: query,
            userLocation: userLocation.lastLocation,
            callback: { (resp: PlacesAutocompleteResponse) in
                DispatchQueue.main.async {
                    // Responses can arrive out of order; ignore any for text that has since changed.
                    guard query == searchInput else { return }
                    autocompleteResults = resp.predictions
                    autocompleteQuery = query
                }
            },
            requestCounter: autocompleteRequestCount,
            userSettings: userSettings
        )
    }

    var body: some View {
        let appclipNavigationBinding = Binding<Bool>(get: {
            appclipNavigationLink != nil
        }, set: { val in
            if !val {
                appclipNavigationLink = nil
            }
        })
        NavigationStack {
            switch userLocation.locationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                List {
                    ForEach(searchResults) { result in
                        NavigationLink(destination: OrienteerView(destinationPlaceType: result.type, destinationPlaceId: result.id, geocoder: geocoder, userLocation: userLocation)) {
                            SearchResultView(name: result.name, subtitle: result.subtitle)
                        }
                    }
                    if !autocompleteResults.isEmpty {
                        // Google requires this attribution wherever Places autocomplete results are shown without a map.
                        Image(colorScheme == .dark ? "PoweredByGoogleDark" : "PoweredByGoogleLight")
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                            .accessibilityLabel("Powered by Google")
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if searchInput.isEmpty {
                        ContentUnavailableView(
                            "Find a destination",
                            systemImage: "location.magnifyingglass",
                            description: Text("Search for a place, or enter coordinates like 37.8199, -122.4783.")
                        )
                    } else if searchResults.isEmpty {
                        if isAwaitingResults {
                            ProgressView()
                        } else {
                            ContentUnavailableView.search(text: searchInput)
                        }
                    }
                }
                .searchable(text: $searchInput, placement: searchFieldPlacement, prompt: "Where you're going")
                .autocorrectionDisabled()
                .onChange(of: searchInput) { _, newValue in
                    search(for: newValue)
                }
                .navigationTitle("Orienteer")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Settings", systemImage: "gearshape") {
                            settingsDisplayed = true
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("History", systemImage: "clock.arrow.circlepath") {
                            historyDisplayed = true
                        }
                    }
                }
                .sheet(isPresented: $settingsDisplayed) {
                    SettingsView(onDismiss: { settingsDisplayed = false })
                }
                .sheet(isPresented: $historyDisplayed) {
                    HistoryView(
                        onDismiss: { historyDisplayed = false },
                        onSelect: { id in
                            historySelectedEntryId = id
                            historyDisplayed = false
                            historyNavigationActive = true
                        }
                    )
                    .environment(\.managedObjectContext, viewContext)
                }
                .navigationDestination(isPresented: $historyNavigationActive) {
                    OrienteerView(destinationPlaceType: "history", destinationPlaceId: historySelectedEntryId?.uuidString ?? "", geocoder: geocoder, userLocation: userLocation)
                }
                .navigationDestination(isPresented: appclipNavigationBinding) {
                    OrienteerView(destinationPlaceType: "appclip", destinationPlaceId: appclipNavigationLink ?? "", geocoder: geocoder, userLocation: userLocation)
                }
            case .notDetermined:
                ContentUnavailableView(
                    "Location Access Needed",
                    systemImage: "location.circle",
                    description: Text("Orienteer uses your location to point you toward your destination.")
                )
            case .denied, .restricted:
                ContentUnavailableView {
                    Label("Location Access Is Off", systemImage: "location.slash")
                } description: {
                    Text("Orienteer needs your location to point you toward a destination. You can turn it on in Settings.")
                } actions: {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            default:
                // Location services report the authorization status almost immediately after launch.
                ProgressView()
            }
        }
        .onContinueUserActivity("NSUserActivityTypeBrowsingWeb", perform: { activity in
            guard activity.activityType == NSUserActivityTypeBrowsingWeb else { return }
            guard let incomingURL = activity.webpageURL else { return }
            appclipNavigationLink = incomingURL.absoluteString
        })
    }
}

#Preview("Empty") {
    SearchView(userLocation: UserLocation(previewMode: true), geocoder: Geocoder())
        .environmentObject(UserSettings())
}

#Preview("Results") {
    let results = [
        ("Golden Gate Bridge", "San Francisco, CA, USA"),
        ("Golden Gate Park", "San Francisco, CA, USA"),
        ("Golden Gate Bakery", "Grant Avenue, San Francisco, CA, USA"),
    ].enumerated().map { index, place in
        PlacesAutocompletePrediction(
            description: "\(place.0), \(place.1)",
            placeId: "preview-\(index)",
            structuredFormatting: PlacesAutocompleteStructuredFormatting(mainText: place.0, secondaryText: place.1)
        )
    }
    SearchView(userLocation: UserLocation(previewMode: true), geocoder: Geocoder(), previewQuery: "Golden Gate", previewResults: results)
        .environmentObject(UserSettings())
}
