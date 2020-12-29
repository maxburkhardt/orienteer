//
//  ContentView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

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
    @EnvironmentObject var userSettings: UserSettings
    var geocoder = Geocoder()
    @State private var searchInput = ""
    @State private var autocompleteResults = [PlacesAutocompletePrediction]()
    @State private var settingsDisplayed = false
    @State private var historyDisplayed = false
    @State private var historySelectedEntryId: UUID? = nil
    @State private var historyNavigationActive = false
    private var autocompleteRequestCount = SynchronizedCounter()
    private let coordinateRegex = try! NSRegularExpression(pattern: "^(-?[0-9]+\\.?[0-9]*)\\s*,\\s*(-?[0-9]+\\.?[0-9]*)$")

    init(userLocation: UserLocation) {
        self.userLocation = userLocation
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

    var body: some View {
        let searchInputBinding = Binding<String>(get: {
            self.searchInput
        }, set: {
            self.searchInput = $0
            geocoder.placesAutocomplete(
                search: self.searchInput,
                userLocation: userLocation.lastLocation,
                callback: { (resp: PlacesAutocompleteResponse) -> Void in
                    autocompleteResults = resp.predictions
                },
                requestCounter: autocompleteRequestCount,
                userSettings: userSettings
            )
        })
        NavigationView {
            if let locationAuthStatus = userLocation.locationStatus {
                if locationAuthStatus == CLAuthorizationStatus.authorizedWhenInUse {
                    VStack {
                        TextField("Where you're going", text: searchInputBinding)
                            .modifier(TextFieldClearButton(text: searchInputBinding))
                            .padding(.vertical, 10.0)
                            .padding(.horizontal, 17.0)
                        NavigationLink(destination: OrienteerView(destinationPlaceType: "history", destinationPlaceId: historySelectedEntryId?.uuidString ?? "", geocoder: geocoder, userLocation: userLocation), isActive: $historyNavigationActive) {}
                        List(searchResults) { result in
                            NavigationLink(destination: OrienteerView(destinationPlaceType: result.type, destinationPlaceId: result.id, geocoder: geocoder, userLocation: userLocation)) {
                                SearchResultView(name: result.name, subtitle: result.subtitle)
                            }
                        }
                        .listStyle(PlainListStyle())
                        HStack {
                            Button(action: { self.settingsDisplayed = true }, label: {
                                Text("Settings")
                            })
                                .sheet(isPresented: self.$settingsDisplayed, content: {
                                    SettingsView(onDismiss: { self.settingsDisplayed = false })
                                })
                                .padding(.vertical, 10.0)
                                .padding(.horizontal, 17.0)
                            Spacer()
                            ActivityIndicator(shouldAnimate: autocompleteRequestCount.value != 0)
                            Spacer()
                            Button(action: { self.historyDisplayed = true }, label: {
                                Text("History")
                            })
                                .sheet(isPresented: self.$historyDisplayed, content: {
                                    HistoryView(
                                        onDismiss: { self.historyDisplayed = false },
                                        onSelect: { id in
                                            historySelectedEntryId = id
                                            historyDisplayed = false
                                            historyNavigationActive = true
                                        }
                                    )
                                    .environment(\.managedObjectContext, self.viewContext)
                                })
                                .padding(.vertical, 10.0)
                                .padding(.horizontal, 17.0)
                        }
                    }
                    .navigationTitle("Find a destination")
                } else if locationAuthStatus == CLAuthorizationStatus.notDetermined {
                    VStack {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 100))
                            .padding(.bottom, 20.0)
                        Text("Please authorize Orienteer to allow it to use location services.")
                    }
                } else {
                    VStack {
                        Image(systemName: "xmark.octagon")
                            .font(.system(size: 100))
                            .padding(.bottom, 20.0)
                        Text("Orienteer requires location access to function.")
                    }
                }
            } else {
                Text("Could not load location authorization status.")
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(userLocation: UserLocation(previewMode: true))
    }
}
