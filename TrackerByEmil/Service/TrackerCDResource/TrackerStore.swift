//
//  TrackerStore.swift
//  TrackerByEmil
//
//  Created by Emil on 17.08.2025.
//

import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addTracker(tracker: Tracker, trackerCategory: TrackerCategory) {
        let trackerCD = TrackerCD(context: context)
        trackerCD.name = tracker.name
        trackerCD.emoji = tracker.emoji
        trackerCD.id = tracker.id
        trackerCD.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerCD.schedule = tracker.schedule.toData()
        
        try? context.save()
    }
}
