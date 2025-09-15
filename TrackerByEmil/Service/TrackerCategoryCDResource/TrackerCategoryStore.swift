//
//  TrackerCategoryStore.swift
//  TrackerByEmil
//

import UIKit
import CoreData

protocol TrackerCategoryStoreProtocol {
    func fetchCategories() -> [TrackerCategoryCD]
    func addCategory(_ category: TrackerCategory) throws
    func deleteCategory(_ category: TrackerCategoryCD) throws
    func updateCategory(_ category: TrackerCategoryCD, newTitle: String) throws
}

final class TrackerCategoryStore: TrackerCategoryStoreProtocol {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchCategories() -> [TrackerCategoryCD] {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCD = TrackerCategoryCD(context: context)
        trackerCategoryCD.title = category.title
        
        for tracker in category.trackerOfCategory {
            let trackerCD = TrackerCD(context: context)
            trackerCD.id = tracker.id
            trackerCD.name = tracker.name
            trackerCD.emoji = tracker.emoji
            trackerCD.color = UIColorMarshalling.hexString(from: tracker.color)
            trackerCD.schedule = tracker.schedule.toData()
            trackerCD.category = trackerCategoryCD
        }
        
        try context.save()
    }
    
    func deleteCategory(_ category: TrackerCategoryCD) throws {
        context.delete(category)
        try context.save()
    }
    
    func updateCategory(_ category: TrackerCategoryCD, newTitle: String) throws {
        category.title = newTitle
        try context.save()
    }
}
