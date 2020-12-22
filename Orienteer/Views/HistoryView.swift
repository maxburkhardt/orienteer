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
    var body: some View {
        VStack {
            Text("History")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 5.0)
            List {
                ForEach(places) { place in
                    SearchResultView(name: place.name ?? "Unknown place", subtitle: visitedFormatter.string(from: place.timestamp ?? Date.distantPast)).onTapGesture { onSelect(place.id!) }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(PlainListStyle())
            HStack {
                Button(action: { deleteItems(offsets: IndexSet(integersIn: 0 ..< places.endIndex)) }, label: {
                    Text("Clear History")
                })
            }
        }
        .padding(10.0)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { places[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let visitedFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(onDismiss: { do {} }, onSelect: { _ in do {} })
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
