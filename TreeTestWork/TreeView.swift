//
//  TreeView.swift
//  TreeTestWork
//
//  Created by Игорь Фрик on 12.10.2023.
//

import SwiftUI
import CoreData

struct TreeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: TreeViewModel
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TreeModel.name, ascending: true)],
        animation: .default)
    var items: FetchedResults<TreeModel>
    
    var body: some View {
        NavigationStack {
            NavigationView {
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            TreeView(viewModel: TreeViewModel(model:item)).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        } label: {
                            Text(item.name!)
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: viewModel.addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
            .navigationTitle(viewModel.model?.name ?? "Root")
        }
    }
    
    private func deleteItem(offsets: IndexSet) {
        offsets.map { items[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    TreeView(viewModel: TreeViewModel()).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
