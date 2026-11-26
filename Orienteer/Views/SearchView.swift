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
            SearchResultListEntry(type: "googleplace", id: result.placeId, name: result.mainText, subtitle: result.secondaryText)
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

    private func statusIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 48))
            .foregroundStyle(.secondary)
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
                        NavigationLink(destination: OrienteerView(destinationPlaceType: result.type, destinationPlaceId: result.id, destinationPlaceName: result.name, geocoder: geocoder, userLocation: userLocation)) {
                            SearchResultView(name: result.name, subtitle: result.subtitle)
                        }
                    }
                    if !autocompleteResults.isEmpty {
                        // Google requires this attribution wherever Places results are shown without a map: the official
                        // logo, unmodified, at its native 18pt height, with at least 10pt clear space to the sides and top.
                        Image("GoogleMapsLogo")
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                            .accessibilityLabel("Google Maps")
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if !searchInput.isEmpty && searchResults.isEmpty {
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
                .navigationTitle("Find a Destination")
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
                    SettingsView()
                }
                .sheet(isPresented: $historyDisplayed) {
                    HistoryView(onSelect: { id in
                        historySelectedEntryId = id
                        historyDisplayed = false
                        historyNavigationActive = true
                    })
                    .environment(\.managedObjectContext, viewContext)
                }
                .navigationDestination(isPresented: $historyNavigationActive) {
                    OrienteerView(destinationPlaceType: "history", destinationPlaceId: historySelectedEntryId?.uuidString ?? "", geocoder: geocoder, userLocation: userLocation)
                }
                .navigationDestination(isPresented: appclipNavigationBinding) {
                    OrienteerView(destinationPlaceType: "appclip", destinationPlaceId: appclipNavigationLink ?? "", geocoder: geocoder, userLocation: userLocation)
                }
            case .notDetermined:
                ContentUnavailableView {
                    statusIcon("mappin.and.ellipse")
                } description: {
                    Text("Please authorize Orienteer to allow it to use location services.")
                }
            case .denied, .restricted:
                ContentUnavailableView {
                    statusIcon("xmark.octagon")
                } description: {
                    Text("Orienteer requires location access to function.")
                } actions: {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            default:
                ContentUnavailableView {
                    statusIcon("exclamationmark.triangle")
                } description: {
                    Text("Could not load location authorization status.")
                }
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
            placeId: "preview-\(index)",
            text: PlacesText(text: "\(place.0), \(place.1)"),
            structuredFormat: PlacesStructuredFormat(mainText: PlacesText(text: place.0), secondaryText: PlacesText(text: place.1))
        )
    }
    SearchView(userLocation: UserLocation(previewMode: true), geocoder: Geocoder(), previewQuery: "Golden Gate", previewResults: results)
        .environmentObject(UserSettings())
}
