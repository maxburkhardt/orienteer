//
//  SearchView.swift
//  WatchOrienteer Extension
//
//  Created by Maximilian Burkhardt on 1/1/21.
//

import SwiftUI

struct ReadyView: View {
    @State private var searchInput = ""

    var body: some View {
        VStack {
            Image(systemName: "location.circle")
                .font(.system(size: 50))
            Text("Please load an Orienteer destination on your phone.")
                .multilineTextAlignment(.center)
        }
    }
}

struct ReadyView_Previews: PreviewProvider {
    static var previews: some View {
        ReadyView()
    }
}
