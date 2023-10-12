//
//  TreeViewModel.swift
//  TreeTestWork
//
//  Created by Игорь Фрик on 12.10.2023.
//

import Foundation
import CoreData
import Combine
import SwiftUI

class TreeViewModel: ObservableObject {
    let persistenceController = PersistenceController.shared.container.viewContext
    
    
    func randomName() -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<20).map{ _ in letters.randomElement()! })
    }
    
    func save() {
        do {
            try persistenceController.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func setRoot() {
        let newItem = TreeModel(context: persistenceController)
        newItem.name = "Root"
        save()
    }
    
    func addItem() {
        let newItem = TreeModel(context: persistenceController)
        newItem.name = randomName()
        save()
    }
}
