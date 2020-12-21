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
                    NavigationLink(destination: OrienteerView(destinationPlaceId: result.placeId, geocoder: geocoder, userLocation: userLocation)) {
                        SearchResultView(candidatePlace: result)
                    }
                }
                HStack {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Settings")
                    }).padding(10.0)
                    Spacer()
                    Button(action: {}, label: {
                        Text("History")
                    }).padding(10.0)
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
