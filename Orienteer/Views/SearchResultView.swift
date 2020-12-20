//
//  SearchResultView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/20/20.
//

import SwiftUI

struct SearchResultView: View {
    var candidatePlace: PlacesAutocompletePrediction
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(candidatePlace.structuredFormatting.mainText)
                    .font(.body)
                    .fontWeight(.bold)
                Spacer()
            }
            HStack {
                Text(candidatePlace.structuredFormatting.secondaryText)
            }
        }
    }
}

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView(candidatePlace: PlacesAutocompletePrediction(description: "Test Place", placeId: "AAA", structuredFormatting: PlacesAutocompleteStructuredFormatting(mainText: "Test Place", secondaryText: "1st St, San Francisco, CA")))
    }
}
