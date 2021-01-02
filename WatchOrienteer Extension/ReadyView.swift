//
//  SearchView.swift
//  WatchOrienteer Extension
//
//  Created by Maximilian Burkhardt on 1/1/21.
//

import SwiftUI

struct ReadyView: View {
    @State private var searchInput = ""
    @EnvironmentObject var phoneConnectionProvider: PhoneConnectionProvider
    @EnvironmentObject var userLocation: UserLocation

    var body: some View {
        let shouldStartOrienteering = Binding<Bool>(
            get: { phoneConnectionProvider.lastMessage != nil },
            set: { _ in phoneConnectionProvider.lastMessage = nil }
        )
        VStack {
            Image(systemName: "location.circle")
                .font(.system(size: 50))
            Text("Please load an Orienteer destination on your phone.")
                .multilineTextAlignment(.center)
            NavigationLink(destination: WatchOrienteerView().environmentObject(userLocation), isActive: shouldStartOrienteering) {}.hidden().frame(width: 1, height: 1, alignment: .center)
        }
        .onAppear {
            if !phoneConnectionProvider.isConnected {
                phoneConnectionProvider.connect()
            }
        }
    }
}

struct ReadyView_Previews: PreviewProvider {
    static var previews: some View {
        ReadyView().environmentObject(UserLocation()).environmentObject(PhoneConnectionProvider())
    }
}
