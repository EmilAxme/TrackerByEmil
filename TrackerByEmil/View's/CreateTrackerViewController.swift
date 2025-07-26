import UIKit

final class CreateTrackerViewController: UIViewController {
    
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
    private var isFormValid: Bool = false
    private var selectedColor: UIColor?
    
    let mockUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    var selectedScheduleDays: [WeekDay] = []
    var delegate: TrackerViewController?
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var characterCounterLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .ypGray
        label.textAlignment = .right
        label.alpha = 0
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var textFieldContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var categoryAndScheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .ypGray
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reusableIdentifier)
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reusableIdentifier)
        return tableView
    }()
    
    private lazy var emojiAndColorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
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
        button.layer.cornerRadius = 16
        button.setTitleColor(.ypRed, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.setTitleColor(.ypWhite, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNavigation()
        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupAppearance() {
        view.backgroundColor = .ypWhite
    }
    
    private func setupNavigation() {
        title = "Новая привычка"
        navigationItem.hidesBackButton = true
    }
    
    private func setupUI() {
        view.addToView(scrollView)
        scrollView.addToView(contentView)
        
        textFieldContainer.addToView(trackerNameTextField)
        textFieldContainer.addToView(characterCounterLabel)
        
        contentView.addToView(textFieldContainer)
        contentView.addToView(categoryAndScheduleTableView)
        contentView.addToView(emojiAndColorCollectionView)
        contentView.addToView(buttonsStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textFieldContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textFieldContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 75),
            
            trackerNameTextField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            trackerNameTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor),
            trackerNameTextField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            characterCounterLabel.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -16),
            characterCounterLabel.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: -8),
            
            categoryAndScheduleTableView.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 24),
            categoryAndScheduleTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryAndScheduleTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryAndScheduleTableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiAndColorCollectionView.topAnchor.constraint(equalTo: categoryAndScheduleTableView.bottomAnchor, constant: 32),
            emojiAndColorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiAndColorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiAndColorCollectionView.heightAnchor.constraint(equalToConstant: 500),
            
            buttonsStackView.topAnchor.constraint(equalTo: emojiAndColorCollectionView.bottomAnchor, constant: 16),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let delegate,
        let selectedColor,
            let selectedEmoji,
            let name = trackerNameTextField.text
        else { return }
        delegate.addNewTracker(
            id: mockUUID,
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            categoryTitle: "Важное"
        )
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.characterCounterLabel.alpha = text.count >= 38 ? 1 : 0
        }
        
        updateCreateButtonStateIfNeeded()
    }
    
    // MARK: - Update UI
    private func updateCreateButtonStateIfNeeded() {
        let isNameEntered = !(trackerNameTextField.text?.isEmpty ?? true)
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isScheduleSelected = !selectedScheduleDays.isEmpty
        
        let isFormNowValid = isNameEntered && isEmojiSelected && isColorSelected && isScheduleSelected
        
        if isFormNowValid != isFormValid {
            isFormValid = isFormNowValid
            createButton.isEnabled = isFormNowValid
            createButton.backgroundColor = isFormNowValid ? .ypBlack : .ypGray
        }
    }
    
    func didChooseSchedule(_ days: [WeekDay]) {
        selectedScheduleDays = days
        self.categoryAndScheduleTableView.reloadData()
        updateCreateButtonStateIfNeeded()
    }
}

// MARK: - UITextFieldDelegate
extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 38
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonStateIfNeeded()
    }
}

// MARK: - UITableViewDataSource
extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedScheduleDays.count == 0 {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reusableIdentifier, for: indexPath) as? CategoryCell else {
                    return UITableViewCell()
                }
                cell.titleLabel.text = "Категория"
                cell.descriptionLabel.text = "Важное"
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.reusableIdentifier, for: indexPath) as? ScheduleCell else {
                    return UITableViewCell()
                }
                cell.titleLabel.text = "Расписание"
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reusableIdentifier, for: indexPath) as? CategoryCell else {
                return UITableViewCell()
            }
            if indexPath.row == 0 {
                cell.titleLabel.text = "Категория"
                cell.descriptionLabel.text = "Важное"
                return cell
            } else {
                cell.titleLabel.text = "Расписание"
                if selectedScheduleDays.count == 7 {
                    cell.descriptionLabel.text = "Каждый день"
                } else {
                    cell.descriptionLabel.text = selectedScheduleDays
                        .map { $0.shortName }
                        .joined(separator: ", ")
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                }
                return cell
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            // Обработка выбора категории
        } else {
            let scheduleSelectViewController = ScheduleSelectViewController()
            scheduleSelectViewController.delegate = self
            scheduleSelectViewController.selectedDays = Set(selectedScheduleDays)
            navigationController?.pushViewController(scheduleSelectViewController, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerEmojiColorCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerEmojiColorCell else {
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
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderTrackerEmojiColorSection.reuseIdentifier,
            for: indexPath
        ) as? HeaderTrackerEmojiColorSection else {
            return UICollectionReusableView()
        }
        
        header.categoryTitle.text = indexPath.section == 0 ? "Emoji" : "Цвет"
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            collectionView.indexPathsForSelectedItems?
                .filter { $0.section == 0 && $0 != indexPath }
                .forEach {
                    collectionView.deselectItem(at: $0, animated: false)
                    if let previousCell = collectionView.cellForItem(at: $0) as? TrackerEmojiColorCell {
                        previousCell.contentView.backgroundColor = .clear
                    }
                }
            
            selectedEmoji = emojis[indexPath.item]
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackerEmojiColorCell {
                UIView.animate(withDuration: 0.2) {
                    cell.layer.masksToBounds = true
                    cell.layer.cornerRadius = 16
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
            
            selectedColor = colors[indexPath.item]
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackerEmojiColorCell {
                UIView.animate(withDuration: 0.2) {
                    cell.layer.borderColor = self.colors[indexPath.item].cgColor
                    cell.layer.borderWidth = 3
                    cell.layer.cornerRadius = 10
                }
            }
        }
        
        updateCreateButtonStateIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TrackerEmojiColorCell {
            UIView.animate(withDuration: 0.2) {
                if indexPath.section == 0 {
                    cell.contentView.backgroundColor = .clear
                } else {
                    cell.layer.borderWidth = 0
                }
            }
        }
        updateCreateButtonStateIfNeeded()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
