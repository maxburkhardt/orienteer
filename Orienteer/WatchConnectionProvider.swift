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
    private var userSettings: UserSettings?
    private var sendQueue: [[String: Any]] = []

    var synchronizedPlace: NavigablePlace? {
        didSet {
            sendPlaceData()
        }
    }

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

    private func sendPlaceData() {
        if let place = synchronizedPlace {
            let message = [
                "type": "place",
                "name": place.name!,
                "latitude": place.latitude,
                "longitude": place.longitude,
                "units": userSettings?.units.rawValue ?? DistanceUnits.metric.rawValue,
            ] as [String: Any]
            sendQueue.append(message)
            if isConnected {
                sendMessagesInQueue()
            }
        }
    }

    func connect(userSettings: UserSettings) {
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
        self.userSettings = userSettings
        session.activate()
    }

    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {
        sendMessagesInQueue()
    }

    func session(_: WCSession, didReceiveMessage message: [String: Any]) {
        switch message["type"] as? String {
        case "sendPlace":
            sendPlaceData()
        default:
            print("Received unknown message from watch: \(String(describing: message["type"]))")
        }
    }

    func sessionDidBecomeInactive(_: WCSession) {}

    func sessionDidDeactivate(_: WCSession) {}

    var isConnected: Bool {
        session.isPaired && session.isReachable
    }
}
