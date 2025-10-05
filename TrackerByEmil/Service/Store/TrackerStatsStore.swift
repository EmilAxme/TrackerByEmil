//
//  TrackerStatsStore.swift
//  TrackerByEmil
//
//  Created by Emil on 20.09.2025.
//

import UIKit

final class TrackerStatsStore {
    private enum Keys {
        static let completedCount = "completedCount"
    }
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func getCompletedCount() -> Int {
        return defaults.integer(forKey: Keys.completedCount)
    }
    
    func addCompleted() {
        let current = getCompletedCount()
        defaults.set(current + 1, forKey: Keys.completedCount)
    }
    
    func removeCompleted() {
        let current = getCompletedCount()
        let newValue = max(0, current - 1)
        defaults.set(newValue, forKey: Keys.completedCount)
    }
    
    func reset() {
        defaults.set(0, forKey: Keys.completedCount)
    }
}
