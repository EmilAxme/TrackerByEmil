//
//  String+Helpers.swift
//  TrackerByEmil
//
//  Created by Emil on 15.09.2025.
//

import Foundation

extension String {
    
    func localizedPlural(_ arg: Int) -> String {
        let formatString = NSLocalizedString(self, comment: "\(self) could not be found in Localizable.stringdict")
        return Self.localizedStringWithFormat(formatString, arg)
    }
    
}
