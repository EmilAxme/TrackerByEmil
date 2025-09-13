//
//  CategorySelectViewModel.swift
//  TrackerByEmil
//

import Foundation

struct CategoryCellViewModel {
    let title: String
    let isSelected: Bool
}

final class CategorySelectViewModel {
    
    // MARK: - Bindings
    var onCategoriesChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Properties
    private let store: TrackerCategoryStoreProtocol
    private(set) var categories: [TrackerCategoryCD] = []
    private var selectedIndexPath: IndexPath?
    
    var hasSelectedCategory: Bool {
        selectedIndexPath != nil
    }
    
    var selectedCategory: TrackerCategoryCD? {
        guard let index = selectedIndexPath else { return nil }
        return categories[index.row]
    }
    
    init(store: TrackerCategoryStoreProtocol) {
        self.store = store
        loadCategories()
    }
    
    // MARK: - Public functions
    func numberOfRows() -> Int {
        categories.count
    }
    
    func cellViewModel(at indexPath: IndexPath) -> CategoryCellViewModel {
        let category = categories[indexPath.row]
        return CategoryCellViewModel(
            title: category.title ?? "",
            isSelected: indexPath == selectedIndexPath
        )
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        selectedIndexPath = indexPath
        onCategoriesChanged?()
    }
    
    func addCategory(title: String) {
        let trackerCategory = TrackerCategory(title: title, trackerOfCategory: [])
        do {
            try store.addCategory(trackerCategory)
            loadCategories()
        } catch {
            onError?("Не удалось добавить категорию")
        }
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        do {
            try store.deleteCategory(category)
            loadCategories()
        } catch {
            onError?("Не удалось удалить категорию")
        }
    }
    
    func updateCategory(at indexPath: IndexPath, newTitle: String) {
        let category = categories[indexPath.row]
        do {
            try store.updateCategory(category, newTitle: newTitle)
            loadCategories()
        } catch {
            onError?("Не удалось обновить категорию")
        }
    }
    
    // MARK: - Private functions
    private func loadCategories() {
        categories = store.fetchCategories()
        onCategoriesChanged?()
    }
}
