//
//  CustomTrackerCell.swift
//  TrackerByEmil
//
//  Created by Emil on 13.06.2025.
//

import UIKit

final class CustomTrackerCell: UICollectionViewCell {

    // MARK: - Layout Constants
    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let emojiSize: CGFloat = 24
        static let emojiTop: CGFloat = 12
        static let emojiLeading: CGFloat = 12
        static let nameBottom: CGFloat = 12
        static let nameHorizontalInset: CGFloat = 12
        static let doneButtonSize: CGFloat = 34
        static let doneButtonTrailing: CGFloat = 12
        static let doneButtonBottom: CGFloat = 16
        static let nameViewHeightMultiplier: CGFloat = 0.608
        static let iconPointSize: CGFloat = 10
        static let animationDuration: TimeInterval = 0.2
    }

    static let reuseIdentifier = "CustomTrackerCell"
    
    // MARK: - Properties
    var onDoneButtonTapped: ((UUID, Bool) -> Void)?
    var onEditTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    private var trackerId: UUID?
    private var isTrackerDone = false
    
    // MARK: - UI Elements
    private lazy var nameAndEmojiView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.cornerRadius
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.clipsToBounds = true
        label.layer.cornerRadius = Layout.emojiSize / 2
        label.backgroundColor = .ypBackground.withAlphaComponent(0.3)
        return label
    }()

    private lazy var trackerName: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: Layout.iconPointSize, weight: .bold)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = Layout.doneButtonSize / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupContextMenu()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupContextMenu()
    }

    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(nameAndEmojiView)
        contentView.addSubview(doneButton)
        contentView.addSubview(daysCountLabel)

        nameAndEmojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerName.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false

        nameAndEmojiView.addSubview(emojiLabel)
        nameAndEmojiView.addSubview(trackerName)

        NSLayoutConstraint.activate([
            nameAndEmojiView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameAndEmojiView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameAndEmojiView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameAndEmojiView.heightAnchor.constraint(equalTo: contentView.heightAnchor,
                                                     multiplier: Layout.nameViewHeightMultiplier),

            emojiLabel.leadingAnchor.constraint(equalTo: nameAndEmojiView.leadingAnchor, constant: Layout.emojiLeading),
            emojiLabel.topAnchor.constraint(equalTo: nameAndEmojiView.topAnchor, constant: Layout.emojiTop),
            emojiLabel.widthAnchor.constraint(equalToConstant: Layout.emojiSize),
            emojiLabel.heightAnchor.constraint(equalToConstant: Layout.emojiSize),

            trackerName.leadingAnchor.constraint(equalTo: nameAndEmojiView.leadingAnchor, constant: Layout.nameHorizontalInset),
            trackerName.trailingAnchor.constraint(equalTo: nameAndEmojiView.trailingAnchor, constant: -Layout.nameHorizontalInset),
            trackerName.bottomAnchor.constraint(equalTo: nameAndEmojiView.bottomAnchor, constant: -Layout.nameBottom),

            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.doneButtonTrailing),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.doneButtonBottom),
            doneButton.widthAnchor.constraint(equalToConstant: Layout.doneButtonSize),
            doneButton.heightAnchor.constraint(equalToConstant: Layout.doneButtonSize),

            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.emojiLeading),
            daysCountLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor)
        ])
    }
    
    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        nameAndEmojiView.addInteraction(interaction) // 👈 контекстное меню только на синей части
    }

    // MARK: - Public
    func configure(source: Tracker, isCompleted: Bool, dayCount: Int) {
        trackerId = source.id
        emojiLabel.text = source.emoji
        trackerName.text = source.name
        nameAndEmojiView.backgroundColor = source.color
        doneButton.backgroundColor = source.color
        daysCountLabel.text = "days_count".localizedPlural(dayCount)
        
        isTrackerDone = isCompleted
        updateCompletionState(isCompleted: isCompleted)
    }

    func updateCompletionState(isCompleted: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: Layout.iconPointSize, weight: .bold)
        let imageName = isCompleted ? "checkmark" : "plus"
        doneButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        doneButton.alpha = isCompleted ? 0.5 : 1.0
    }
    
    func isFuture(isActive: Bool) {
        doneButton.isEnabled = isActive
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        guard let trackerId else { return }
        let newIsCompleted = !isTrackerDone
        isTrackerDone = newIsCompleted
        onDoneButtonTapped?(trackerId, newIsCompleted)
    }
}

// MARK: - Context Menu
extension CustomTrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.onEditTapped?()
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.onDeleteTapped?()
            }
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}

