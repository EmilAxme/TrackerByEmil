//
//  TrackerRecordStore.swift
//  TrackerByEmil
//
//  Created by Emil on 17.08.2025.
//

import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func trackerRecordSave(trackerRecord: TrackerRecord) {
        let trackerRecordCD = TrackerRecordCD(context: context)
        trackerRecordCD.id = trackerRecord.id
        trackerRecordCD.date = trackerRecord.date
        
        try? context.save()
    }
}
