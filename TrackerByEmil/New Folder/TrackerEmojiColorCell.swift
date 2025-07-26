//
//  TrackerEmojiColorCell.swift
//  TrackerByEmil
//
//  Created by Emil on 16.06.2025.
//

import UIKit

class TrackerEmojiColorCell: UICollectionViewCell {
    // MARK: - Properties
    static let reuseIdentifier = "TrackerEmojiColorCell"
    
    // MARK: - UI Element's
    lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.font = .systemFont(ofSize: 32, weight: .bold)
        emojiLabel.textAlignment = .center
        return emojiLabel
    }()
    
    lazy var colorView: UIView = {
        let colorView = UIView()
        colorView.layer.masksToBounds = true
        colorView.layer.cornerRadius = 8
        return colorView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private functions
    private func setupUI() {
        
        [emojiLabel,
         colorView].forEach {
            contentView.addToView($0)
        }
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant:-6),
            
            emojiLabel.heightAnchor.constraint(equalToConstant: 40),
            emojiLabel.widthAnchor.constraint(equalToConstant: 40),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
}
