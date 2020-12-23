//
//  UIDeviceOrientation.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/22/20.
//

import CoreLocation
import Foundation
import SwiftUI

extension UIDeviceOrientation {
    func convertToCLDeviceOrientation() -> CLDeviceOrientation {
        switch self {
        case .landscapeLeft:
            return CLDeviceOrientation.landscapeLeft
        case .landscapeRight:
            return CLDeviceOrientation.landscapeRight
        case .portrait:
            return CLDeviceOrientation.portrait
        case .portraitUpsideDown:
            return CLDeviceOrientation.portraitUpsideDown
        case .faceDown:
            return CLDeviceOrientation.faceDown
        case .faceUp:
            return CLDeviceOrientation.faceUp
        case .unknown:
            return CLDeviceOrientation.unknown
        default:
            return CLDeviceOrientation.unknown
        }
    }
}
