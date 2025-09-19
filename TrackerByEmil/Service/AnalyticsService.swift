//
//  AnalyticsService.swift
//  TrackerByEmil
//
//  Created by Emil on 18.09.2025.
//

import AppMetricaCore

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}

protocol AnalyticsServiceProtocol {
    func reportEvent(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?)
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func reportEvent(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        var parameters: [AnyHashable: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        
        if let item = item {
            parameters["item"] = item.rawValue
        }
        
        AppMetrica.reportEvent(name: "ui_event", parameters: parameters) { error in
            print("AppMetrica error: \(error.localizedDescription)")
        }
    }
}
