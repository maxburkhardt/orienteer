//
//  SynchronizedCounter.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/22/20.
//

import Foundation

class SynchronizedCounter {
    private var queue = DispatchQueue(label: "SynchronizedCounterQueue")
    private(set) var value: Int = 0

    func increment() {
        queue.sync {
            value += 1
        }
    }

    func decrement() {
        queue.sync {
            value -= 1
        }
    }
}
