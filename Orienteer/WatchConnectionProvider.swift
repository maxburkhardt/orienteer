//
//  WatchConnectionProvider.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 1/1/21.
//

import Foundation
import WatchConnectivity

class WatchConnectionProvider: NSObject, WCSessionDelegate, ObservableObject {
    private let session: WCSession
    private var sendQueue: [[String: Any]] = []

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
    }

    private func sendMessagesInQueue() {
        for message in sendQueue {
            session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Send error: \(error.localizedDescription)")
            })
        }
    }

    func connect() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
        session.activate()
    }

    func sendPlaceInformation(place: NavigablePlace, settings: UserSettings) {
        let message = [
            "name": place.name!,
            "latitude": place.latitude,
            "longitude": place.longitude,
            "units": settings.units.rawValue,
        ] as [String: Any]
        sendQueue.append(message)
        if isConnected {
            sendMessagesInQueue()
        }
    }

    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {
        sendMessagesInQueue()
    }

    func sessionDidBecomeInactive(_: WCSession) {}

    func sessionDidDeactivate(_: WCSession) {}

    var isConnected: Bool {
        session.isPaired && session.isReachable
    }
}
