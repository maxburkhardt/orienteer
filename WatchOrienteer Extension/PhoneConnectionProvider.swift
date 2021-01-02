//
//  PhoneConnectionProvider.swift
//  WatchOrienteer Extension
//
//  Created by Maximilian Burkhardt on 1/1/21.
//

import Foundation
import WatchConnectivity

class PhoneConnectionProvider: NSObject, WCSessionDelegate, ObservableObject {
    private let session: WCSession
    @Published var lastMessage: [String: Any]? = nil

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
    }

    func connect() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
        session.activate()
    }

    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {}

    func session(_: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.lastMessage = message
        }
    }

    var isConnected: Bool {
        session.isReachable
    }
}
