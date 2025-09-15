//
//  TrackerRecordProvider.swift
//  TrackerByEmil
//
//  Created by Emil on 24.08.2025.
//

import CoreData

struct TrackerRecordStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerRecordProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerRecordStoreUpdate)
}

protocol TrackerRecordProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerRecordCD?
    func addRecord(_ record: TrackerRecord) throws
    func deleteRecord(at indexPath: IndexPath) throws

    func removeRecord(_ record: TrackerRecord) throws   // ✅ новый
    func fetchAllRecords() -> [TrackerRecord]           // ✅ новый
}

final class TrackerRecordProvider: NSObject {
    private let coreDataStack: CoreDataStackProtocol
    weak var delegate: TrackerRecordProviderDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCD> = {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    init(coreDataStack: CoreDataStackProtocol, delegate: TrackerRecordProviderDelegate? = nil) {
        self.coreDataStack = coreDataStack
        self.delegate = delegate
        super.init()
    }
}

extension TrackerRecordProvider: TrackerRecordProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerRecordCD? {
        fetchedResultsController.object(at: indexPath)
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let recordCD = TrackerRecordCD(context: coreDataStack.context)
        recordCD.id = record.id
        recordCD.date = record.date
        try coreDataStack.context.save()
    }
    
    func deleteRecord(at indexPath: IndexPath) throws {
        let record = fetchedResultsController.object(at: indexPath)
        coreDataStack.context.delete(record)
        try coreDataStack.context.save()
    }
    
    func removeRecord(_ record: TrackerRecord) throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: record.date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@ AND (date >= %@) AND (date < %@)",
            record.id as CVarArg,
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )

        if let existing = try coreDataStack.context.fetch(request).first {
            coreDataStack.context.delete(existing)
            try coreDataStack.context.save()
        }
    }

    func fetchAllRecords() -> [TrackerRecord] {
        let recordsCD = fetchedResultsController.fetchedObjects ?? []
        return recordsCD.compactMap { recordCD in
            guard let id = recordCD.id, let date = recordCD.date else { return nil }
            return TrackerRecord(id: id, date: date)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let inserted = insertedIndexes, let deleted = deletedIndexes {
            delegate?.didUpdate(TrackerRecordStoreUpdate(insertedIndexes: inserted, deletedIndexes: deleted))
        }
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        default:
            print("Неверно выбран тип изменения")
        }
    }
}
