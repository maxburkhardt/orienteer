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
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select a destination")
                .font(.title)
                .multilineTextAlignment(.leading)
                .padding(10.0)
            HStack {
                TextField("Where you're going", text: $searchInput)
                Button(action: {
                    geocoder.searchForPlace(search: searchInput, location: userLocation.lastLocation)
                }) {
                    Text("Search")
                }
                Spacer()
                    .frame(width: 5)
            }
            .padding(10.0)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
