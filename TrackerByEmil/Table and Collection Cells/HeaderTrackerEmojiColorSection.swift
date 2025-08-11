//
//  HeaderTrackerEmojiColorSection.swift
//  TrackerByEmil
//
//  Created by Emil on 16.06.2025.
//

import UIKit

final class HeaderTrackerEmojiColorSection: UICollectionReusableView {

    // MARK: - Layout Constants
    
    private enum Layout {
        static let leadingInset: CGFloat = 28
    }

    // MARK: - Properties

    static let reuseIdentifier = "HeaderTrackerEmojiColorSection"
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

    // MARK: - Private methods

    private func setupUI() {
        categoryTitle.font = .systemFont(ofSize: 19, weight: .bold)

        addToView(categoryTitle)

        NSLayoutConstraint.activate([
            categoryTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.leadingInset),
            categoryTitle.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
