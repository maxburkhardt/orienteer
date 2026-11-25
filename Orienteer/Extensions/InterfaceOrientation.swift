//
//  InterfaceOrientation.swift
//  Orienteer
//

import CoreLocation
import SwiftUI
import UIKit

/// Reports the interface orientation of the window scene hosting this view, initially and whenever it rotates.
///
/// This is what the user sees on screen, unlike `UIDevice.orientation`: it is never face up/down or unknown,
/// and it doesn't change when the device is turned to an orientation the interface doesn't support
/// (such as upside down on iPhone).
struct InterfaceOrientationReader: UIViewRepresentable {
    var onChange: (UIInterfaceOrientation) -> Void

    func makeUIView(context _: Context) -> ReaderView {
        let view = ReaderView()
        view.isUserInteractionEnabled = false
        view.onChange = onChange
        return view
    }

    func updateUIView(_ view: ReaderView, context _: Context) {
        view.onChange = onChange
    }

    final class ReaderView: UIView {
        var onChange: ((UIInterfaceOrientation) -> Void)?
        private var observation: NSKeyValueObservation?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            // effectiveGeometry is key-value observable and changes on every rotation, including
            // 180° landscape flips that leave the view's size unchanged.
            observation = window?.windowScene?.observe(\.effectiveGeometry, options: [.initial, .new]) { [weak self] scene, _ in
                self?.onChange?(scene.effectiveGeometry.interfaceOrientation)
            }
        }
    }
}

extension UIInterfaceOrientation {
    /// The device orientation CoreLocation should measure headings from so that they line up with this interface orientation.
    var headingOrientation: CLDeviceOrientation? {
        switch self {
        case .portrait: .portrait
        case .portraitUpsideDown: .portraitUpsideDown
        // Interface and device landscape orientations are named oppositely: the interface is
        // landscapeLeft when the device is rotated to landscapeRight, and vice versa.
        case .landscapeLeft: .landscapeRight
        case .landscapeRight: .landscapeLeft
        default: nil
        }
    }
}
