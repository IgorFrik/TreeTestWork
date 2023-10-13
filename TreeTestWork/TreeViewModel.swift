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
    @Published var model: TreeModel?
    
    init() {
        let count = try? persistenceController.count(for: NSFetchRequest(entityName: "TreeModel"))
        print(count!)
        if count == 0 {
            setRoot()
        } else {
            setView()
            //            deleteAll()
        }
    }
    
    init(model: TreeModel?) {
        self.model = model
    }
    
    func setDefaultModelName() {
        UserDefaults.standard.set(model?.name ?? "Root", forKey: "root")
    }
    
    func getModel() -> TreeModel? {
        self.model
    }
    
    func addChildren(parent: TreeModel) {
        let newItem = TreeModel(context: persistenceController)
        newItem.name = randomName()
        newItem.parent = parent
        save()
    }
    
    func deleteItem(offsets: IndexSet) {
        let items = try! persistenceController.fetch(NSFetchRequest(entityName: "TreeModel"))
            .map { $0 as! TreeModel }
            .filter { $0.parent == self.model}
        let newItems = items.sorted { $0.name! < $1.name!}
        offsets
            .map { newItems[$0] }
            .forEach { elem in
                print(elem)
            }
        save()
    }
    
    // MARK: - private func
    private func randomName() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<20).map{ _ in letters.randomElement()! })
    }
    
    private func save() {
        do {
            try persistenceController.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func setRoot() {
        let newItem = TreeModel(context: persistenceController)
        newItem.name = "Root"
        newItem.parent = nil
        self.model = newItem
        self.save()
    }
    
    private func setView() {
        let root = try! persistenceController.fetch(NSFetchRequest(entityName: "TreeModel"))
        self.model = root
            .map{ $0 as! TreeModel }
            .filter{ $0.name == UserDefaults.standard.string(forKey: "root")!}
            .first
    }
    
    private func deleteAll() {
        let root = try! persistenceController.fetch(NSFetchRequest(entityName: "TreeModel"))
        root.forEach({ elem in
            persistenceController.delete(elem as! NSManagedObject)
        })
    }
}
