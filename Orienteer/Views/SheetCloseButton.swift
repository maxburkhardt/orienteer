//
//  SheetCloseButton.swift
//  Orienteer
//

import SwiftUI

/// The toolbar button that dismisses a sheet: the system close (✕) button on iOS 26, a text button before that.
struct SheetCloseButton: View {
    var title: LocalizedStringKey = "Done"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if #available(iOS 26, *) {
            Button(role: .close) { dismiss() }
        } else {
            Button(title) { dismiss() }
                .fontWeight(.semibold)
        }
    }
}
