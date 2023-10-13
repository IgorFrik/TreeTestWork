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
                    ForEach(items.filter{ $0.parent == viewModel.getModel()}) { item in
                        NavigationLink {
                            TreeView(viewModel: TreeViewModel(model:item)).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        } label: {
                            Text(item.name ?? "Error")
                        }
                    }
                    .onDelete(perform: viewModel.deleteItem)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.getModel()?.parent == nil { } else {
                        NavigationLink {
                            TreeView(viewModel: TreeViewModel(model:viewModel.getModel()?.parent)).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        } label: {
                            Text(verbatim: "Back to \(viewModel.getModel()?.parent?.name ?? "Error")")
                        }
                    }
                }
                ToolbarItem {
                    Button(action: {
                        viewModel.addChildren(parent: self.viewModel.getModel()!)
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(viewModel.getModel()?.name ?? "Error")
            .onAppear {
                viewModel.setDefaultModelName()
            }
        }
    }
}

#Preview {
    TreeView(viewModel: TreeViewModel()).environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

