//
//  CoreDataStack.swift
//  TrackerByEmil
//
//  Created by Emil on 17.08.2025.
//
//
import UIKit
import CoreData

final class CoreDataStack {
    lazy var context = persistentContainer.viewContext
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "TrackerModels")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    print("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }
}
