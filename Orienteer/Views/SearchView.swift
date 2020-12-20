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
                session: autocompleteSession,
                callback: { (resp: PlacesAutocompleteResponse) -> Void in
                    autocompleteResults = resp.predictions
                }
            )
        })
        VStack(alignment: .leading) {
            Text("Select a destination")
                .font(.title)
                .multilineTextAlignment(.leading)
                .padding(10.0)
            HStack {
                TextField("Where you're going", text: searchInputBinding)
                Button(action: {
                    geocoder.findPlaceFromText(
                        search: searchInput,
                        userLocation: userLocation.lastLocation!,
                        callback: {(resp: FindPlaceResponse) -> Void in print(resp.candidates.first?.formattedAddress ?? "Not found")}
                    )
                }) {
                    Text("Search")
                }
                Spacer()
                    .frame(width: 5)
            }
            .padding(10.0)
            List(autocompleteResults) { result in
                SearchResultView(candidatePlace: result)
            }
            Spacer()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
