//
//  SearchResultView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/20/20.
//

import SwiftUI

struct SearchResultView: View {
    var name: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(name)
                    .fontWeight(.bold)
                Spacer()
            }
            HStack {
                Text(subtitle ?? "")
            }
        }
        .contentShape(Rectangle())
    }
}

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView(name: "Test Place", subtitle: "1st St, San Francisco, CA")
    }
}
