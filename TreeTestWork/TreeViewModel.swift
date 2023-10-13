//
//  TreeViewModel.swift
//  TreeTestWork
//
//  Created by Игорь Фрик on 12.10.2023.
//

import Foundation
import CoreData

class TreeViewModel: ObservableObject {
    let persistenceController = PersistenceController.shared.container.viewContext
    @Published var model: TreeModel?
    
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
    }
    
    func setDefaultModelName() {
        UserDefaults.standard.set(model?.name ?? "Root", forKey: "root")
    }
    
    func getModel() -> TreeModel? {
        self.model
    }
    
    func addChildren(parent: TreeModel) {
        let newItem = TreeModel(context: persistenceController)
        newItem.name = hexName()
        newItem.parent = parent
        save()
    }
    
    func deleteItem(offsets: IndexSet) {
        let items = try! persistenceController.fetch(NSFetchRequest(entityName: "TreeModel"))
            .map { $0 as! TreeModel }
        let newItems = items
            .sorted { $0.name! < $1.name!}
            .filter { $0.parent == self.model}
        offsets
            .map { newItems[$0] }
            .forEach(persistenceController.delete)
        save()
        items
            .filter { $0.parent == nil && $0.name != "Root" }
            .forEach(persistenceController.delete)
        save()
    }
    
    // MARK: - private func
    private func hexName() -> String {
        var keyData = Data(count: 20)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 20, $0.baseAddress!)
        }
        if result == errSecSuccess {
            return keyData.base64EncodedString()
        } else {
            print("Problem generating random bytes")
            return "Error"
        }
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
// MARK: - for delete all TreeModel
    private func deleteAll() {
        let root = try! persistenceController.fetch(NSFetchRequest(entityName: "TreeModel"))
        root.forEach({ elem in
            persistenceController.delete(elem as! NSManagedObject)
        })
    }
}
