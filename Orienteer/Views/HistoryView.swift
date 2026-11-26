//
//  HistoryView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/21/20.
//

import CoreData
import SwiftUI

struct HistoryView: View {
    var onSelect: (UUID) -> Void
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NavigablePlace.timestamp, ascending: false)],
        animation: .default
    )
    private var places: FetchedResults<NavigablePlace>
    @State private var alertMessage = ""
    @State private var showingConfirmation = false

    var body: some View {
        let showAlertBinding = Binding<Bool>(get: {
            alertMessage != ""
        }, set: { _ in
            alertMessage = ""
        })
        NavigationStack {
            List {
                ForEach(places) { place in
                    Button {
                        if let id = place.id {
                            onSelect(id)
                        }
                    } label: {
                        SearchResultView(name: place.name ?? "Unknown place", subtitle: place.timestamp.map { visitedFormatter.string(from: $0) })
                    }
                    .tint(.primary)
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(.plain)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear History", role: .destructive) {
                        showingConfirmation = true
                    }
                    .disabled(places.isEmpty)
                    .confirmationDialog("Are you sure you want to clear history?", isPresented: $showingConfirmation, titleVisibility: .visible) {
                        Button("Yes, Clear", role: .destructive) {
                            deleteItems(offsets: IndexSet(integersIn: 0 ..< places.endIndex))
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This action cannot be undone.")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SheetCloseButton()
                }
            }
        }
        .presentationDetents([.medium, .large])
        .alert("Error", isPresented: showAlertBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { places[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                alertMessage = nsError.localizedDescription
            }
        }
    }
}

private let visitedFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    HistoryView(onSelect: { _ in })
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
