//
//  TrackerCategoryProvider.swift
//  TrackerByEmil
//
//  Created by Emil on 24.08.2025.
//

import CoreData

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerCategoryProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

protocol TrackerCategoryProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at indexPath: IndexPath) -> TrackerCategoryCD?
    func addCategory(_ category: TrackerCategory) throws
    func deleteCategory(at indexPath: IndexPath) throws
}

final class TrackerCategoryProvider: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryProviderDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD> = {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    init(context: NSManagedObjectContext, delegate: TrackerCategoryProviderDelegate) {
        self.context = context
        self.delegate = delegate
        super.init()
    }
}

extension TrackerCategoryProvider: TrackerCategoryProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategoryCD? {
        fetchedResultsController.object(at: indexPath)
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCD = TrackerCategoryCD(context: context)
        categoryCD.title = category.title
        
        for tracker in category.trackerOfCategory {
            let trackerCD = TrackerCD(context: context)
            trackerCD.id = tracker.id
            trackerCD.name = tracker.name
            trackerCD.emoji = tracker.emoji
            trackerCD.color = UIColorMarshalling.hexString(from: tracker.color)
            trackerCD.schedule = tracker.schedule.toData()
            
            trackerCD.category = categoryCD // связь
        }
        
        try context.save()
    }
    
    func deleteCategory(at indexPath: IndexPath) throws {
        let category = fetchedResultsController.object(at: indexPath)
        context.delete(category)
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let inserted = insertedIndexes, let deleted = deletedIndexes {
            delegate?.didUpdate(TrackerCategoryStoreUpdate(insertedIndexes: inserted, deletedIndexes: deleted))
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
