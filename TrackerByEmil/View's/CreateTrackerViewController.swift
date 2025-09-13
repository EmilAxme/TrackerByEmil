import UIKit

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Layout Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let defaultSpacing: CGFloat = 24
        static let smallSpacing: CGFloat = 8
        static let mediumSpacing: CGFloat = 16
        static let largeSpacing: CGFloat = 32
        static let textFieldHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let cellHeight: CGFloat = 75
        static let scheduleTableHeight: CGFloat = 150
        static let collectionViewHeight: CGFloat = 500
        static let headerHeight: CGFloat = 50
        static let sidePadding: CGFloat = 16
        static let wideSidePadding: CGFloat = 20
        static let textFieldLeftPadding: CGFloat = 16
        static let characterCounterRightPadding: CGFloat = 16
        static let characterCounterBottomPadding: CGFloat = 8
        static let collectionItemSize: CGFloat = 52
        static let collectionSectionInset: CGFloat = 18
        static let collectionHeaderTopInset: CGFloat = 24
        static let colorBorderWidth: CGFloat = 3
        static let colorCornerRadius: CGFloat = 10
        static let emojiCornerRadius: CGFloat = 16
        static let maxCharacterCount: Int = 38
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
    var selectedScheduleDays: [WeekDay] = []
    var selectedCategory = ""
    
    private var isFormValid: Bool = false
    var delegate: TrackerViewController?
    
    // MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var characterCounterLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение \(Constants.maxCharacterCount) символов"
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
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.textFieldLeftPadding, height: textField.frame.height))
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
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Constants.sidePadding, bottom: 0, right: Constants.sidePadding)
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
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
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
        
        textFieldContainer.addToView(trackerNameTextField)
        textFieldContainer.addToView(characterCounterLabel)
        
        scrollView.addToView(textFieldContainer)
        scrollView.addToView(categoryAndScheduleTableView)
        scrollView.addToView(emojiAndColorCollectionView)
        scrollView.addToView(buttonsStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            textFieldContainer.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Constants.defaultSpacing),
            textFieldContainer.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Constants.sidePadding),
            textFieldContainer.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Constants.sidePadding),
            textFieldContainer.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            trackerNameTextField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            trackerNameTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor),
            trackerNameTextField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            characterCounterLabel.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -Constants.characterCounterRightPadding),
            characterCounterLabel.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: -Constants.characterCounterBottomPadding),
            
            categoryAndScheduleTableView.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: Constants.defaultSpacing),
            categoryAndScheduleTableView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Constants.sidePadding),
            categoryAndScheduleTableView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Constants.sidePadding),
            categoryAndScheduleTableView.heightAnchor.constraint(equalToConstant: Constants.scheduleTableHeight),
            
            emojiAndColorCollectionView.topAnchor.constraint(equalTo: categoryAndScheduleTableView.bottomAnchor, constant: Constants.largeSpacing),
            emojiAndColorCollectionView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Constants.sidePadding),
            emojiAndColorCollectionView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Constants.sidePadding),
            emojiAndColorCollectionView.heightAnchor.constraint(equalToConstant: Constants.collectionViewHeight),
            
            buttonsStackView.topAnchor.constraint(equalTo: emojiAndColorCollectionView.bottomAnchor, constant: Constants.mediumSpacing),
            buttonsStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Constants.wideSidePadding),
            buttonsStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Constants.wideSidePadding),
            buttonsStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    private func createTracker() -> Tracker? {
        guard let trackerName = trackerNameTextField.text,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else {
            return nil
        }
        
        return Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedScheduleDays
        )
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        delegate?.loadTrackersFromCoreData()
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let tracker = createTracker() else { return }
        let categoryName = selectedCategory
        delegate?.loadTrackersFromCoreData()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.addNewTracker(tracker, to: categoryName)
            self.dismiss(animated: true)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            UIView.animate(withDuration: Constants.animationDuration) {
                self.characterCounterLabel.alpha = text.count >= Constants.maxCharacterCount ? 1 : 0
            }
        }
        
        updateCreateButtonStateIfNeeded()
    }
    
    // MARK: - Update UI
    
    private func updateCreateButtonStateIfNeeded() {
        let isNameEntered = !(trackerNameTextField.text?.isEmpty ?? true)
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isScheduleSelected = !selectedScheduleDays.isEmpty
        let trackerCategorySelected = !selectedCategory.isEmpty
        
        let isFormNowValid = isNameEntered && isEmojiSelected && isColorSelected && isScheduleSelected && trackerCategorySelected
        
        if isFormNowValid != isFormValid {
            isFormValid = isFormNowValid
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.createButton.isEnabled = isFormNowValid
                self.createButton.backgroundColor = isFormNowValid ? .ypBlack : .ypGray
            }
        }
    }
    
    func didChooseSchedule(_ days: [WeekDay]) {
        selectedScheduleDays = days
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.categoryAndScheduleTableView.reloadData()

        }
        self.updateCreateButtonStateIfNeeded()
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
        
        return updatedText.count <= Constants.maxCharacterCount
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
        if selectedScheduleDays.isEmpty {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reusableIdentifier, for: indexPath) as? CategoryCell else {
                    return UITableViewCell()
                }
                cell.titleLabel.text = "Категория"
                cell.descriptionLabel.text = selectedCategory.isEmpty ? "Выберите или создайте :)" : selectedCategory
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
                cell.descriptionLabel.text = selectedCategory.isEmpty ? "Выберите или создайте :)" : selectedCategory
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
        return Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            guard let coreDataStack = (delegate)?.coreDataStack else { return }
            let store = TrackerCategoryStore(context: coreDataStack.context)
            let vm = CategorySelectViewModel(store: store)
            let categorySelectViewController = CategorySelectViewController(viewModel: vm)
            categorySelectViewController.delegate = self
            present(UINavigationController(rootViewController: categorySelectViewController), animated: true)
        } else {
            let scheduleSelectViewController = ScheduleSelectViewController()
            scheduleSelectViewController.delegate = self
            scheduleSelectViewController.selectedDays = Set(selectedScheduleDays)
            present(UINavigationController(rootViewController: scheduleSelectViewController), animated: true)
        }
    }
}

// MARK: - CategorySelectViewControllerDelegate

extension CreateTrackerViewController: CategorySelectViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategoryCD) {
        self.selectedCategory = category.title ?? ""  
        DispatchQueue.main.async {
            self.categoryAndScheduleTableView.reloadData()
            self.updateCreateButtonStateIfNeeded()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
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

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constants.headerHeight)
    }
}
