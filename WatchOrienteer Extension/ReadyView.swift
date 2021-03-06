//
//  SearchView.swift
//  WatchOrienteer Extension
//
//  Created by Maximilian Burkhardt on 1/1/21.
//

import SwiftUI

struct ReadyView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var searchInput = ""
    @ObservedObject var phoneConnectionProvider: PhoneConnectionProvider
    @ObservedObject var userLocation: UserLocation

    private func attemptToGetPlace() {
        if !phoneConnectionProvider.isConnected {
            phoneConnectionProvider.connect()
        } else {
            phoneConnectionProvider.requestPlace()
        }
    }

    var body: some View {
        let shouldStartOrienteering = Binding<Bool>(
            get: { phoneConnectionProvider.lastMessage != nil },
            set: { _ in phoneConnectionProvider.lastMessage = nil }
        )
        let destination = CLLocation(
            latitude: phoneConnectionProvider.lastMessage?["latitude"] as? Double ?? 0.0 as CLLocationDegrees,
            longitude: phoneConnectionProvider.lastMessage?["longitude"] as? Double ?? 0.0 as CLLocationDegrees
        )
        let units = DistanceUnits(rawValue: phoneConnectionProvider.lastMessage?["units"] as? String ?? "metric") ?? DistanceUnits.metric
        let name = phoneConnectionProvider.lastMessage?["name"] as? String ?? "Destination"
        VStack {
            Image(systemName: "location.circle")
                .font(.system(size: 50))
            Text("Please load an Orienteer destination on your phone.")
                .multilineTextAlignment(.center)
            NavigationLink(
                destination: WatchOrienteerView(
                    userLocation: userLocation,
                    destinationName: name,
                    destinationCoordinates: destination,
                    units: units
                )
                .environmentObject(userLocation),
                isActive: shouldStartOrienteering
            ) {}
                .hidden()
                .frame(width: 1, height: 1, alignment: .center)
        }
        .onAppear {
            attemptToGetPlace()
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                attemptToGetPlace()
            default:
                // Do nothing
                do {}
            }
        }
    }
}

struct ReadyView_Previews: PreviewProvider {
    static var previews: some View {
        ReadyView(phoneConnectionProvider: PhoneConnectionProvider(), userLocation: UserLocation())
    }
}
