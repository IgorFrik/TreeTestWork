//
//  TreeTestWorkApp.swift
//  TreeTestWork
//
//  Created by Игорь Фрик on 12.10.2023.
//

import SwiftUI

@main
struct TreeTestWorkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TreeView(viewModel: TreeViewModel())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
