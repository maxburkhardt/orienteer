//
//  ContentView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var userLocation = UserLocation()
    var geocoder = Geocoder()
    @State private var searchInput = ""
    @State private var autocompleteResults = [PlacesAutocompletePrediction]()
    @State private var settingsDisplayed = false
    @State private var historyDisplayed = false
    @Environment(\.managedObjectContext) var moc

    var body: some View {
        let searchInputBinding = Binding<String>(get: {
            self.searchInput
        }, set: {
            self.searchInput = $0
            geocoder.placesAutocomplete(
                search: self.searchInput,
                userLocation: userLocation.lastLocation!,
                callback: { (resp: PlacesAutocompleteResponse) -> Void in
                    autocompleteResults = resp.predictions
                }
            )
        })
        NavigationView {
            VStack {
                TextField("Where you're going", text: searchInputBinding)
                    .padding(10.0)
                List(autocompleteResults) { result in
                    NavigationLink(destination: OrienteerView(destinationPlaceType: "googleplace", destinationPlaceId: result.placeId, geocoder: geocoder, userLocation: userLocation)) {
                        SearchResultView(name: result.structuredFormatting.mainText, subtitle: result.structuredFormatting.secondaryText)
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
                        .padding(10.0)
                    Spacer()
                    Button(action: { self.historyDisplayed = true }, label: {
                        Text("History")
                    })
                        .sheet(isPresented: self.$historyDisplayed, content: {
                            HistoryView(onDismiss: { self.historyDisplayed = false })
                                .environment(\.managedObjectContext, self.moc)
                        })
                        .padding(10.0)
                }
            }
            .navigationTitle("Find a destination")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
