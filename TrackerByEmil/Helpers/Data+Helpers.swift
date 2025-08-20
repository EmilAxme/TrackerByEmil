//
//  Data+Helpers.swift
//  TrackerByEmil
//
//  Created by Emil on 17.08.2025.
//

import UIKit

extension Array where Element == WeekDay {
    func toData() -> Data? {
        try? JSONEncoder().encode(self.map { $0.rawValue })
    }
}

extension Data {
    func toWeekDays() -> [WeekDay] {
        guard let rawValues = try? JSONDecoder().decode([Int].self, from: self) else { return [] }
        return rawValues.compactMap { WeekDay(rawValue: $0) }
    }
}
