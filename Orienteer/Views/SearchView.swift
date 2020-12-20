//
//  ContentView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var userLocation = UserLocation()
    @State private var searchInput = ""
    private var geocoder = Geocoder()
    private var autocompleteSession = UUID().uuidString
    @State private var autocompleteResults = Array<PlacesAutocompletePrediction>()
    
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
                    NavigationLink(destination: OrienteerView(destinationPlaceId: result.placeId, geocoder: geocoder)) {
                        SearchResultView(candidatePlace: result)
                    }
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
