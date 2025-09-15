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
        static let opacityWhenPressed: Float = 0.3
    }

    // MARK: - Properties

    static let reuseIdentifier = "CustomTrackerCell"
    
    private var dayCount = 0 {
        didSet {
            updateDaysCountLabel()
        }
    }
    private var isTrackerDone = false
    
    var onDoneButtonTapped: ((UUID, Bool) -> Void)?
    private var trackerId: UUID?

    // MARK: - UI Elements

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

    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        updateDaysCountLabel()
        return label
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: Layout.iconPointSize, weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: config)

        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = Layout.doneButtonSize / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var nameAndEmojiView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Layout.cornerRadius
        view.clipsToBounds = true
        return view
    }()

    private lazy var pinnedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pin.fill")
        imageView.tintColor = .white
        imageView.isHidden = true
        return imageView
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
        contentView.layer.cornerRadius = Layout.cornerRadius
        contentView.clipsToBounds = true

        nameAndEmojiView.addToView(emojiLabel)
        nameAndEmojiView.addToView(trackerName)
        nameAndEmojiView.addToView(pinnedImageView)
        contentView.addToView(nameAndEmojiView)
        contentView.addToView(daysCountLabel)
        contentView.addToView(doneButton)

        NSLayoutConstraint.activate([
            nameAndEmojiView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameAndEmojiView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameAndEmojiView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameAndEmojiView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: Layout.nameViewHeightMultiplier),

            emojiLabel.leadingAnchor.constraint(equalTo: nameAndEmojiView.leadingAnchor, constant: Layout.emojiLeading),
            emojiLabel.topAnchor.constraint(equalTo: nameAndEmojiView.topAnchor, constant: Layout.emojiTop),
            emojiLabel.widthAnchor.constraint(equalToConstant: Layout.emojiSize),
            emojiLabel.heightAnchor.constraint(equalToConstant: Layout.emojiSize),

            trackerName.leadingAnchor.constraint(equalTo: nameAndEmojiView.leadingAnchor, constant: Layout.nameHorizontalInset),
            trackerName.trailingAnchor.constraint(equalTo: nameAndEmojiView.trailingAnchor, constant: -Layout.nameHorizontalInset),
            trackerName.bottomAnchor.constraint(equalTo: nameAndEmojiView.bottomAnchor, constant: -Layout.nameBottom),

            pinnedImageView.trailingAnchor.constraint(equalTo: nameAndEmojiView.trailingAnchor, constant: -Layout.emojiLeading),
            pinnedImageView.topAnchor.constraint(equalTo: nameAndEmojiView.topAnchor, constant: Layout.emojiTop),
            pinnedImageView.widthAnchor.constraint(equalToConstant: Layout.emojiSize / 2),
            pinnedImageView.heightAnchor.constraint(equalToConstant: Layout.emojiSize / 2),

            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.doneButtonTrailing),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.doneButtonBottom),
            doneButton.widthAnchor.constraint(equalToConstant: Layout.doneButtonSize),
            doneButton.heightAnchor.constraint(equalToConstant: Layout.doneButtonSize),

            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.emojiLeading),
            daysCountLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor)
        ])
    }

    private func updateDaysCountLabel() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.daysCountLabel.text = "\(self.dayCount) \(self.dayWord(for: self.dayCount))"
        }
    }

    private func dayWord(for number: Int) -> String {
        let lastTwoDigits = number % 100
        let lastDigit = number % 10

        if (11...14).contains(lastTwoDigits) {
            return "дней"
        }

        switch lastDigit {
        case 1: return "день"
        case 2, 3, 4: return "дня"
        default: return "дней"
        }
    }

    // MARK: - Public Methods

    func configure(source: Tracker, isCompleted: Bool, dayCount: Int) {
        trackerId = source.id
        emojiLabel.text = source.emoji
        trackerName.text = source.name
        nameAndEmojiView.backgroundColor = source.color
        doneButton.backgroundColor = source.color

        isTrackerDone = isCompleted
        updateCompletionState(isCompleted: isCompleted)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.daysCountLabel.text = "\(dayCount) \(dayWord(for: dayCount))"
        }
    }
    
    func isFuture(isActive: Bool) {
        doneButton.isEnabled = isActive
    }

    func updateCompletionState(isCompleted: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: Layout.iconPointSize, weight: .bold)
        let imageName = isCompleted ? "checkmark" : "plus"
        doneButton.layer.opacity = isCompleted ? 0.5 : 1
        doneButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }

    // MARK: - Actions

    @objc private func doneButtonTapped() {
        guard let trackerId = trackerId else { return }
        let newIsCompleted = !isTrackerDone
        isTrackerDone = newIsCompleted
        onDoneButtonTapped?(trackerId, newIsCompleted)
    }
    
}
