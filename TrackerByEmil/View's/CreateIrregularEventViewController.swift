//
//  CreateIrregularEventViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 13.07.2025.
//

import UIKit

final class CreateIrregularEventViewController: UIViewController {
    
    // MARK: - Layout Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let defaultSpacing: CGFloat = 24
        static let mediumSpacing: CGFloat = 16
        static let smallSpacing: CGFloat = 8
        static let largeSpacing: CGFloat = 32
        static let textFieldHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let cellHeight: CGFloat = 75
        static let sidePadding: CGFloat = 16
        static let wideSidePadding: CGFloat = 20
        static let textFieldLeftPadding: CGFloat = 16
        static let collectionItemSize: CGFloat = 52
        static let collectionSectionInset: CGFloat = 18
        static let collectionHeaderTopInset: CGFloat = 24
        static let collectionViewHeight: CGFloat = 500
        static let headerHeight: CGFloat = 50
        static let emojiCornerRadius: CGFloat = 16
        static let colorBorderWidth: CGFloat = 3
        static let colorCornerRadius: CGFloat = 10
        static let animationDuration: TimeInterval = 0.3
    }
    
    // MARK: - Properties
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😴"
    ]
    
    private let colors: [UIColor] = [
        UIColor(hex: "#FD4C49"), UIColor(hex: "#FF881E"),
        UIColor(hex: "#007BFA"), UIColor(hex: "#6E44FE"),
        UIColor(hex: "#33CF69"), UIColor(hex: "#E66DD4"),
        UIColor(hex: "#F9D4D4"), UIColor(hex: "#34A7FE"),
        UIColor(hex: "#46E69D"), UIColor(hex: "#35347C"),
        UIColor(hex: "#FF674D"), UIColor(hex: "#FF99CC"),
        UIColor(hex: "#F6C48B"), UIColor(hex: "#7994F5"),
        UIColor(hex: "#832CF1"), UIColor(hex: "#AD56DA"),
        UIColor(hex: "#8D72E6"), UIColor(hex: "#2FD058")
    ]
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var isFormValid: Bool = false
    private var allDays: [WeekDay] = [.friday, .saturday, .sunday, .monday, .tuesday, .wednesday, .thursday]
    var delegate: TrackerViewController?
    
    // MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.textFieldLeftPadding, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    private lazy var categoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .ypGray
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reusableIdentifier)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private lazy var emojiAndColorCollectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Constants.collectionItemSize, height: Constants.collectionItemSize)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(
            top: Constants.collectionHeaderTopInset,
            left: Constants.collectionSectionInset,
            bottom: Constants.collectionHeaderTopInset,
            right: Constants.collectionSectionInset
        )
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = true
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerEmojiColorCell.self, forCellWithReuseIdentifier: TrackerEmojiColorCell.reuseIdentifier)
        collectionView.register(HeaderTrackerEmojiColorSection.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderTrackerEmojiColorSection.reuseIdentifier)
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = Constants.cornerRadius
        button.setTitleColor(.ypRed, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = Constants.cornerRadius
        button.setTitleColor(.ypWhite, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = Constants.smallSpacing
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAppearance()
        setupNavigation()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.addToView(scrollView)

        [trackerNameTextField,
         categoryTableView,
         emojiAndColorCollectionView,
         buttonsStackView].forEach {
            scrollView.addToView($0)
        }

        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            trackerNameTextField.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Constants.defaultSpacing),
            trackerNameTextField.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Constants.sidePadding),
            trackerNameTextField.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Constants.sidePadding),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),

            categoryTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: Constants.defaultSpacing),
            categoryTableView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Constants.sidePadding),
            categoryTableView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Constants.sidePadding),
            categoryTableView.heightAnchor.constraint(equalToConstant: Constants.cellHeight),

            emojiAndColorCollectionView.topAnchor.constraint(equalTo: categoryTableView.bottomAnchor, constant: Constants.largeSpacing),
            emojiAndColorCollectionView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Constants.sidePadding),
            emojiAndColorCollectionView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Constants.sidePadding),
            emojiAndColorCollectionView.heightAnchor.constraint(equalToConstant: Constants.collectionViewHeight),

            buttonsStackView.topAnchor.constraint(equalTo: emojiAndColorCollectionView.bottomAnchor, constant: Constants.mediumSpacing),
            buttonsStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Constants.wideSidePadding),
            buttonsStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Constants.wideSidePadding),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            buttonsStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Constants.defaultSpacing)
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = .ypWhite
    }
    
    private func setupNavigation() {
        title = "Новое нерегулярное событие"
        navigationItem.hidesBackButton = true
    }
    
    private func updateCreateButtonState() {
        let isNameEntered = !(trackerNameTextField.text?.isEmpty ?? true)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.createButton.isEnabled = isNameEntered
            self.createButton.backgroundColor = isNameEntered ? .ypBlack : .ypGray
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            self.delegate?.addNewTracker(
                id: UUID(),
                name: self.trackerNameTextField.text ?? "",
                color: selectedColor ?? .ypRed,
                emoji: selectedEmoji ?? "😄",
                categoryTitle: "Важное",
                schedule: allDays
            )
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - Update UI
    
    private func updateCreateButtonStateIfNeeded() {
        let isNameEntered = !(trackerNameTextField.text?.isEmpty ?? true)
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        
        let isFormNowValid = isNameEntered && isEmojiSelected && isColorSelected
        
        if isFormNowValid != isFormValid {
            isFormValid = isFormNowValid
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.createButton.isEnabled = isFormNowValid
                self.createButton.backgroundColor = isFormNowValid ? .ypBlack : .ypGray
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension CreateIrregularEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
}

// MARK: - UITableViewDataSource

extension CreateIrregularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reusableIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = "Категория"
        cell.descriptionLabel.text = "Важное"
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
}

// MARK: - UITableViewDelegate

extension CreateIrregularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.cellHeight
    }
}

// MARK: - UICollectionViewDataSource

extension CreateIrregularEventViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerEmojiColorCell.reuseIdentifier, for: indexPath) as? TrackerEmojiColorCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.section == 0 {
            cell.emojiLabel.text = emojis[indexPath.item]
        } else {
            cell.colorView.backgroundColor = colors[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderTrackerEmojiColorSection.reuseIdentifier, for: indexPath) as? HeaderTrackerEmojiColorSection else {
            return UICollectionReusableView()
        }
        
        headerView.categoryTitle.text = indexPath.section == 0 ? "Emoji" : "Color"
        return headerView
    }
}

// MARK: - UICollectionViewDelegate

extension CreateIrregularEventViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if indexPath.section == 0 {
                collectionView.indexPathsForSelectedItems?
                    .filter { $0.section == 0 && $0 != indexPath }
                    .forEach {
                        collectionView.deselectItem(at: $0, animated: false)
                        if let previousCell = collectionView.cellForItem(at: $0) as? TrackerEmojiColorCell {
                            previousCell.contentView.backgroundColor = .clear
                        }
                    }
                
                self.selectedEmoji = self.emojis[indexPath.item]
                
                if let cell = collectionView.cellForItem(at: indexPath) as? TrackerEmojiColorCell {
                    UIView.animate(withDuration: Constants.animationDuration) {
                        cell.layer.masksToBounds = true
                        cell.layer.cornerRadius = Constants.emojiCornerRadius
                        cell.contentView.backgroundColor = .ypLightGray
                    }
                }
                
            } else if indexPath.section == 1 {
                collectionView.indexPathsForSelectedItems?
                    .filter { $0.section == 1 && $0 != indexPath }
                    .forEach {
                        collectionView.deselectItem(at: $0, animated: false)
                        if let previousCell = collectionView.cellForItem(at: $0) as? TrackerEmojiColorCell {
                            previousCell.layer.borderWidth = 0
                        }
                    }
                
                self.selectedColor = self.colors[indexPath.item]
                
                if let cell = collectionView.cellForItem(at: indexPath) as? TrackerEmojiColorCell {
                    UIView.animate(withDuration: Constants.animationDuration) {
                        cell.layer.borderColor = self.colors[indexPath.item].cgColor
                        cell.layer.borderWidth = Constants.colorBorderWidth
                        cell.layer.cornerRadius = Constants.colorCornerRadius
                    }
                }
            }
            
            self.updateCreateButtonStateIfNeeded()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackerEmojiColorCell {
                UIView.animate(withDuration: Constants.animationDuration) {
                    if indexPath.section == 0 {
                        cell.contentView.backgroundColor = .clear
                    } else {
                        cell.layer.borderWidth = 0
                    }
                }
            }
            self.updateCreateButtonStateIfNeeded()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CreateIrregularEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constants.headerHeight)
    }
}
