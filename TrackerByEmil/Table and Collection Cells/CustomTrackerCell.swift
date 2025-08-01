//
//  CustomTrackerCell.swift
//  TrackerByEmil
//
//  Created by Emil on 13.06.2025.
//

import UIKit

final class CustomTrackerCell: UICollectionViewCell {

    // MARK: - Properties
    
    static let reuseIdentifier = "CustomTrackerCell"
    var dayCount = 0
    
    // MARK: - UI Elements
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 12
        label.backgroundColor = .ypBackground
        return label
    }()
    
    private lazy var trackerName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        return label
    }()

    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.text = "\(dayCount) дней"
        return label
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: config)
        
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return button
    }()

    private lazy var nameAndEmojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Lifecycle
    
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
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        nameAndEmojiView.addToView(emojiLabel)
        nameAndEmojiView.addToView(trackerName)
        contentView.addToView(nameAndEmojiView)
        contentView.addToView(daysCountLabel)
        contentView.addToView(doneButton)
        
        NSLayoutConstraint.activate([
            nameAndEmojiView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameAndEmojiView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameAndEmojiView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameAndEmojiView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.608),
            
            emojiLabel.leadingAnchor.constraint(equalTo: nameAndEmojiView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: nameAndEmojiView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            trackerName.leadingAnchor.constraint(equalTo: nameAndEmojiView.leadingAnchor, constant: 12),
            trackerName.trailingAnchor.constraint(equalTo: nameAndEmojiView.trailingAnchor, constant: -12),
            trackerName.bottomAnchor.constraint(equalTo: nameAndEmojiView.bottomAnchor, constant: -12),
            
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor)
        ])
    }
    
    private func dayWord(for number: Int) -> String {
        let lastTwoDigits = number % 100
        let lastDigit = number % 10

        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "дней"
        }

        switch lastDigit {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
    
    // MARK: - Public Methods
    
    func configure(source: Tracker) {
        emojiLabel.text = source.emoji
        trackerName.text = source.name
        nameAndEmojiView.backgroundColor = source.color
        doneButton.backgroundColor = source.color
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        UIView.animate(withDuration: 0.2, animations: {
            self.doneButton.layer.opacity = 0.3
        }, completion: { isFinished in
            if isFinished {
                let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
                let image = UIImage(systemName: "checkmark", withConfiguration: config)
                self.doneButton.setImage(image, for: .normal)
            }
        })
        dayCount += 1
        daysCountLabel.text = "\(dayCount) \(dayWord(for: dayCount))"
    }
    
}
