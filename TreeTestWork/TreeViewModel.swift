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
    @Published var child: [TreeModel] = []
    
    init() {
        let count = try? persistenceController.count(for: NSFetchRequest(entityName: "TreeModel"))
        if count == 0 {
            setRoot()
        } else {
            setView()
        }
    }
    
    init(model: TreeModel?) {
        self.model = model
        setChild()
    }
    
    func addChildren(parent: TreeModel) {
        let newItem = TreeModel(context: persistenceController)
        newItem.name = randomName()
        newItem.parent = parent
        setChild()
        save()
    }
    
    func setChild() {
        self.child = getChild()
    }
    
    func setDefaultModelName() {
        UserDefaults.standard.set(model?.name ?? "Root", forKey: "root")
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
        root.forEach({ elem in
            let elem = elem as! TreeModel
            if elem.name == UserDefaults.standard.string(forKey: "root")! {
                self.model = elem
                setChild()
            }
        })
    }
    
    private func getChild() -> [TreeModel] {
        self.model?.child?.allObjects as? [TreeModel] ?? []
    }
    
    private func deleteAll() {
        let root = try! persistenceController.fetch(NSFetchRequest(entityName: "TreeModel"))
        root.forEach({ elem in
            persistenceController.delete(elem as! NSManagedObject)
        })
    }
}
