//
//  TrackerCategoryStore.swift
//  TrackerByEmil
//
//  Created by Emil on 17.08.2025.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addTrackerCategory(trackerCategory: TrackerCategory) {
        let trackerCategoryCD = TrackerCategoryCD(context: context)
        trackerCategoryCD.title = trackerCategory.title
        
        for tracker in trackerCategory.trackerOfCategory {
            let trackerCD = TrackerCD(context: context)
            trackerCD.id = tracker.id
            trackerCD.name = tracker.name
            trackerCD.emoji = tracker.emoji
            trackerCD.color = UIColorMarshalling.hexString(from: tracker.color)
            trackerCD.schedule = tracker.schedule.toData()
            
            trackerCD.category = trackerCategoryCD
        }
        
        try? context.save()
    }
}
