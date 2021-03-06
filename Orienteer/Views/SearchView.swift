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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userSettings: UserSettings
    var geocoder: Geocoder
    @State private var searchInput = ""
    @State private var autocompleteResults = [PlacesAutocompletePrediction]()
    @State private var settingsDisplayed = false
    @State private var historyDisplayed = false
    @State private var historySelectedEntryId: UUID? = nil
    @State private var historyNavigationActive = false
    @State private var appclipNavigationLink: String? = nil
    private var autocompleteRequestCount = SynchronizedCounter()
    private let coordinateRegex = try! NSRegularExpression(pattern: "^(-?[0-9]+\\.?[0-9]*)\\s*,\\s*(-?[0-9]+\\.?[0-9]*)$")

    init(userLocation: UserLocation, geocoder: Geocoder) {
        self.userLocation = userLocation
        self.geocoder = geocoder
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
        let appclipNavigationBinding = Binding<Bool>(get: {
            appclipNavigationLink != nil
        }, set: { val in
            if !val {
                appclipNavigationLink = nil
            }
        })
        NavigationView {
            if let locationAuthStatus = userLocation.locationStatus {
                if locationAuthStatus == CLAuthorizationStatus.authorizedWhenInUse {
                    VStack {
                        HStack {
                            TextField("Where you're going", text: searchInputBinding)
                                .modifier(TextFieldClearButton(text: searchInputBinding))
                                .padding(.vertical, 10.0)
                                .padding(.horizontal, 17.0)
                            ActivityIndicator(shouldAnimate: autocompleteRequestCount.value != 0)
                                .padding(.trailing, 7.0)
                        }
                        NavigationLink(destination: OrienteerView(destinationPlaceType: "history", destinationPlaceId: historySelectedEntryId?.uuidString ?? "", geocoder: geocoder, userLocation: userLocation), isActive: $historyNavigationActive) {}
                        NavigationLink(destination: OrienteerView(destinationPlaceType: "appclip", destinationPlaceId: appclipNavigationLink ?? "", geocoder: geocoder, userLocation: userLocation), isActive: appclipNavigationBinding) {}
                        List(searchResults) { result in
                            NavigationLink(destination: OrienteerView(destinationPlaceType: result.type, destinationPlaceId: result.id, geocoder: geocoder, userLocation: userLocation)) {
                                SearchResultView(name: result.name, subtitle: result.subtitle)
                            }
                        }
                        .listStyle(PlainListStyle())

                        HStack {
                            Button(action: { self.settingsDisplayed = true }, label: {
                                Image(systemName: "gearshape.fill")
                            })
                                .sheet(isPresented: self.$settingsDisplayed, content: {
                                    SettingsView(onDismiss: { self.settingsDisplayed = false })
                                })
                                .padding(.vertical, 10.0)
                                .padding(.horizontal, 17.0)
                            Spacer()
                            Image(colorScheme == .dark ? "PoweredByGoogleDark" : "PoweredByGoogleLight")
                            Spacer()
                            Button(action: { self.historyDisplayed = true }, label: {
                                Image(systemName: "book.fill")
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
        .navigationViewStyle(StackNavigationViewStyle())
        .onContinueUserActivity("NSUserActivityTypeBrowsingWeb", perform: { activity in
            guard activity.activityType == NSUserActivityTypeBrowsingWeb else { return }
            guard let incomingURL = activity.webpageURL else { return }
            appclipNavigationLink = incomingURL.absoluteString
        })
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(userLocation: UserLocation(previewMode: true), geocoder: Geocoder())
    }
}
