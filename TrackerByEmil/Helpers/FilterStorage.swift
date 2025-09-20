//
//  FilterStorage.swift
//  TrackerByEmil
//
//  Created by Emil on 19.09.2025.
//

import Foundation

final class FilterStorage {
    private enum Keys {
        static let selectedFilterIndex = "selectedFilterIndex"
    }
    
    func save(_ filter: TrackerFilter) {
        if let index = TrackerFilter.allCases.firstIndex(of: filter) {
            UserDefaults.standard.set(index, forKey: Keys.selectedFilterIndex)
        }
    }
    
    func load() -> TrackerFilter {
        guard let index = UserDefaults.standard.value(forKey: Keys.selectedFilterIndex) as? Int,
              index < TrackerFilter.allCases.count else {
            return .all
        }
        return TrackerFilter.allCases[index]
    }
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: Keys.selectedFilterIndex)
    }
}
