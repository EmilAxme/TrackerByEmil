//
//  TrackerEmojiColorCell.swift
//  TrackerByEmil
//
//  Created by Emil on 16.06.2025.
//

import UIKit

final class TrackerEmojiColorCell: UICollectionViewCell {
    
    // MARK: - Layout Constants
    
    private enum Layout {
        static let cornerRadius: CGFloat = 8
        static let padding: CGFloat = 6
        static let emojiSize: CGFloat = 40
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "TrackerEmojiColorCell"

    // MARK: - UI Elements
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Layout.cornerRadius
        return view
    }()
    
    // MARK: - Initialization
    
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
        [colorView, emojiLabel].forEach { contentView.addToView($0) }
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.padding),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.padding),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.padding),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.padding),
            
            emojiLabel.widthAnchor.constraint(equalToConstant: Layout.emojiSize),
            emojiLabel.heightAnchor.constraint(equalToConstant: Layout.emojiSize),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
