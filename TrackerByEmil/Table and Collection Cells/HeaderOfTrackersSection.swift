//
//  Untitled.swift
//  TrackerByEmil
//
//  Created by Emil on 13.06.2025.
//

import UIKit

final class HeaderOfTrackersSection: UICollectionReusableView {
    
    // MARK: - Layout Constants
    
    private enum Layout {
        static let leadingInset: CGFloat = 28
        static let bottomInset: CGFloat = 12
    }

    // MARK: - Properties

    static let reuseIdentifier = "CustomTrackerHeader"
    let categoryTitle = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assertionFailure("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func setupUI() {
        addToView(categoryTitle)
        
        categoryTitle.font = .systemFont(ofSize: 19, weight: .bold)

        NSLayoutConstraint.activate([
            categoryTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.leadingInset),
            categoryTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.bottomInset)
        ])
    }
}
