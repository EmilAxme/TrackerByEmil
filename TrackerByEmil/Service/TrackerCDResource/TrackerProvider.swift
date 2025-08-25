//
//  TrackerProvider.swift
//  TrackerByEmil
//
//  Created by Emil on 24.08.2025.
//

import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

protocol TrackerProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCD?
    func addTracker(_ tracker: Tracker, to category: TrackerCategoryCD) throws
    func deleteTracker(at indexPath: IndexPath) throws
}

final class TrackerProvider: NSObject, TrackerProviderProtocol {
    enum ProviderError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: TrackerProviderDelegate?
    
    private let coreDataStack: CoreDataStackProtocol
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCD> = {
        let request: NSFetchRequest<TrackerCD> = TrackerCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    init(coreDataStack: CoreDataStackProtocol, delegate: TrackerProviderDelegate? = nil) {
        self.coreDataStack = coreDataStack
        self.delegate = delegate
        super.init()
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCD? {
        fetchedResultsController.object(at: indexPath)
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategoryCD) throws {
        let trackerCD = TrackerCD(context: coreDataStack.context)
        trackerCD.id = tracker.id
        trackerCD.name = tracker.name
        trackerCD.emoji = tracker.emoji
        trackerCD.color = UIColorMarshalling.hexString(from: tracker.color)
        trackerCD.schedule = tracker.schedule.toData()
        trackerCD.category = category
        
        coreDataStack.saveContext()
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let tracker = fetchedResultsController.object(at: indexPath)
        coreDataStack.context.delete(tracker)
        coreDataStack.saveContext()
    }
}

extension TrackerProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        insertedSections = IndexSet()
        deletedSections = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let inserted = insertedIndexes,
           let deleted = deletedIndexes,
           let insertedSections = insertedSections,
           let deletedSections = deletedSections {
            delegate?.didUpdate(TrackerStoreUpdate(
                insertedIndexes: inserted,
                deletedIndexes: deleted,
                insertedSections: insertedSections,
                deletedSections: deletedSections
            ))
        }
        insertedIndexes = nil
        deletedIndexes = nil
        insertedSections = nil
        deletedSections = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections?.insert(sectionIndex)
        case .delete:
            deletedSections?.insert(sectionIndex)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
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
            print("Wrong type: \(type)")
        }
    }
}

