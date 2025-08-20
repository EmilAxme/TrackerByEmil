//
//  UIColor+Helpers.swift
//  TrackerByEmil
//
//  Created by Emil on 11.08.2025.
//

import UIKit

final class UIColorMarshalling {
    static func hexString(from color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(red * 255)),
            lroundf(Float(green * 255)),
            lroundf(Float(blue * 255))
        )
    }
    
    static func color(from hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
