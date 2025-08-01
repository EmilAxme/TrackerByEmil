//
//  HeaderTrackerEmojiColorSection.swift
//  TrackerByEmil
//
//  Created by Emil on 16.06.2025.
//

import UIKit

final class HeaderTrackerEmojiColorSection: UICollectionReusableView {
    
    // MARK: - Properties
    static let reuseIdentifier = "HeaderTrackerEmojiColorSection"
    let categoryTitle = UILabel()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        categoryTitle.font = .systemFont(ofSize: 19, weight: .bold)
        
        addToView(categoryTitle)
        
        NSLayoutConstraint.activate([
            categoryTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            categoryTitle.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
