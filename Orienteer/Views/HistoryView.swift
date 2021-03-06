//
//  HistoryView.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/21/20.
//

import CoreData
import SwiftUI

struct HistoryView: View {
    var onDismiss: () -> Void
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
        VStack(alignment: .leading) {
            Text("History")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical, 10.0)
            List {
                ForEach(places) { place in
                    SearchResultView(name: place.name ?? "Unknown place", subtitle: visitedFormatter.string(from: place.timestamp ?? Date.distantPast)).onTapGesture { onSelect(place.id!) }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(PlainListStyle())
            HStack {
                Spacer()
                Button(action: { showingConfirmation = true }, label: {
                    Text("Clear History")
                })
                Spacer()
            }
        }
        .padding(10.0)
        .alert(isPresented: showAlertBinding) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showingConfirmation) {
            Alert(title: Text("Are you sure you want to clear history?"), message: Text("This action cannot be undone."), primaryButton: .destructive(Text("Yes, clear")) {
                deleteItems(offsets: IndexSet(integersIn: 0 ..< places.endIndex))
            }, secondaryButton: .cancel())
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

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(onDismiss: { do {} }, onSelect: { _ in do {} })
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
