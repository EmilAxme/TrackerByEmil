//
//  EditTrackerViewModel.swift
//  TrackerByEmil
//
//  Created by Emil on 17.09.2025.
//

import UIKit

// MARK: - ViewModel
final class EditTrackerViewModel {
    // MARK: - Properties
    private(set) var tracker: Tracker
    private(set) var category: String
    private(set) var completedDays: Int
    
    private(set) var selectedEmoji: String?
    private(set) var selectedColor: UIColor?
    private(set) var selectedScheduleDays: [WeekDay]
    private(set) var selectedCategory: String
    
    var onStateChanged: (() -> Void)?
    
    var isFormValid: Bool {
        let isNameEntered = !(tracker.name.isEmpty)
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isScheduleSelected = !selectedScheduleDays.isEmpty
        let trackerCategorySelected = !selectedCategory.isEmpty
        return isNameEntered && isEmojiSelected && isColorSelected && isScheduleSelected && trackerCategorySelected
    }
    
    init(tracker: Tracker, category: String, completedDays: Int) {
        self.tracker = tracker
        self.category = category
        self.completedDays = completedDays
        self.selectedEmoji = tracker.emoji
        self.selectedColor = tracker.color
        self.selectedScheduleDays = tracker.schedule
        self.selectedCategory = category
    }
    
    // MARK: - Update methods
    func updateName(_ name: String) {
        tracker = Tracker(
            id: tracker.id,
            name: name,
            color: selectedColor ?? tracker.color,
            emoji: selectedEmoji ?? tracker.emoji,
            schedule: selectedScheduleDays
        )
        onStateChanged?()
    }
    
    func updateEmoji(_ emoji: String) {
        selectedEmoji = emoji
        onStateChanged?()
    }
    
    func clearEmoji() {
        selectedEmoji = nil
        onStateChanged?()
    }
    
    func updateColor(_ color: UIColor) {
        selectedColor = color
        onStateChanged?()
    }
    
    func clearColor() {
        selectedColor = nil
        onStateChanged?()
    }
    
    func updateSchedule(_ days: [WeekDay]) {
        selectedScheduleDays = days
        onStateChanged?()
    }
    
    func updateCategory(_ category: String) {
        selectedCategory = category
        onStateChanged?()
    }
    
    func buildUpdatedTracker() -> Tracker {
        Tracker(
            id: tracker.id,
            name: tracker.name,
            color: selectedColor ?? tracker.color,
            emoji: selectedEmoji ?? tracker.emoji,
            schedule: selectedScheduleDays
        )
    }
}
