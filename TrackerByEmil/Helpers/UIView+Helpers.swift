//
//  UIView+Helpers.swift
//  TrackerByEmil
//
//  Created by Emil on 02.06.2025.
//

import UIKit

extension UIView {
    // MARK: - Functions
    func addToView(_ subView: UIView) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
    }
}
