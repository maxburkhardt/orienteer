//
//  OrienteerView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/20/20.
//

import SwiftUI

struct OrienteerView: View {
    var destinationPlaceId: String
    var geocoder: Geocoder
    @State private var destinationPlace: GooglePlacesPlace? = nil
    
    var body: some View {
        VStack {
            Text("Now you're orienteering!")
            Text("Going to: \(destinationPlaceId)")
        }
        .navigationTitle(destinationPlace?.name ?? "Loading...")
        .onAppear() {
            geocoder.placeDetails(placeId: destinationPlaceId, callback: {(place: GooglePlacesPlace) -> Void in
                destinationPlace = place
            })
        }
    }
}

struct OrienteerView_Previews: PreviewProvider {
    static var previews: some View {
        OrienteerView(destinationPlaceId: "ChIJIQBpAG2ahYAR_6128GcTUEo", geocoder: Geocoder())
    }
}
