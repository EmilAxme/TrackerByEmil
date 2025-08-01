//
//  Untitled.swift
//  TrackerByEmil
//
//  Created by Emil on 13.06.2025.
//

import UIKit

final class HeaderOfSection: UICollectionReusableView {
    static let reuseIdentifier = "CustomTrackerHeader"
    let categoryTitle = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addToView(categoryTitle)
        
        NSLayoutConstraint.activate([
            categoryTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            categoryTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
}
