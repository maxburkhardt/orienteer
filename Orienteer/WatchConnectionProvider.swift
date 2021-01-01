//
//  WatchConnectionProvider.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 1/1/21.
//

import Foundation
import WatchConnectivity

class WatchConnectionProvider: NSObject, WCSessionDelegate {
    private let session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
    }

    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {
        print("watch session invoked")
    }

    func sessionDidBecomeInactive(_: WCSession) {
        print("watch session inactive")
    }

    func sessionDidDeactivate(_: WCSession) {
        print("watch session deactivated")
    }
}
