//
//  AppSettings.swift
//  TrackerByEmil
//
//  Created by Emil on 13.09.2025.
//

import UIKit

final class AppSettings {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
    
    static var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasSeenOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hasSeenOnboarding) }
    }
}
