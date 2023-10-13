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
                    ForEach(viewModel.child) { item in
                        NavigationLink {
                            TreeView(viewModel: TreeViewModel(model:item)).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        } label: {
                            Text(item.name ?? "Error")
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.model?.parent == nil { } else {
                        NavigationLink {
                            TreeView(viewModel: TreeViewModel(model:viewModel.model?.parent)).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        } label: {
                            Text(verbatim: "Back to \(viewModel.model?.parent?.name ?? "Error")")
                        }
                    }
                }
                ToolbarItem {
                    Button(action: {
                        viewModel.addChildren(parent: self.viewModel.model!)
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(viewModel.model?.name ?? "Error")
            .onAppear {
                viewModel.setChild()
                viewModel.setDefaultModelName()
            }
        }
    }
    
    private func deleteItem(offsets: IndexSet) {
        print(offsets.forEach({ elem in
            print(elem)
        }))
//        offsets.map { items[$0] }.forEach(viewContext.delete)
//        do {
//            try viewContext.save()
//            viewModel.setChild()
//        } catch {
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
    }
}

#Preview {
    TreeView(viewModel: TreeViewModel()).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

