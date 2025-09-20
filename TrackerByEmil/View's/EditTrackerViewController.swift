import UIKit

final class EditTrackerViewController: UIViewController {
    
    private enum Constants {
        // Layout
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
        
        static let titleNewHabit = "new_habit_title".localized
        static let placeholderName = "tracker_name_placeholder".localized
        static let cancelButtonTitle = "cancel_button".localized
        static let createButtonTitle = "create_button".localized
        static let categoryTitle = "category_title".localized
        static let scheduleTitle = "schedule_title".localized
        static let everyDay = "every_day".localized
        static let chooseOrCreate = "choose_or_create".localized
        static let emojiHeader = "emoji_header".localized
        static let colorHeader = "color_header".localized
        
        static func charLimit(_ limit: Int) -> String {
            String(format: "character_limit".localized, limit)
        }
    }
    
    // MARK: - Dependencies
    private let viewModel: EditTrackerViewModel
    weak var delegate: TrackerViewController?
    
    // MARK: - Data
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
    
    // MARK: - UI
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var characterCounterLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.charLimit(Constants.maxCharacterCount)
        label.font = .systemFont(ofSize: 13)
        label.textColor = .ypGray
        label.textAlignment = .right
        label.alpha = 0
        return label
    }()
    
    private lazy var completedDaysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.placeholderName
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.textFieldLeftPadding, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.text = viewModel.buildUpdatedTracker().name
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
        button.setTitle(Constants.cancelButtonTitle, for: .normal)
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
        button.setTitle("Сохранить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = Constants.cornerRadius
        button.setTitleColor(.ypWhite, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = Constants.smallSpacing
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Init
    init(viewModel: EditTrackerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNavigation()
        setupUI()
        updateUI()
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] in
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        completedDaysLabel.text = "\(viewModel.completedDays) дней"
        createButton.isEnabled = viewModel.isFormValid
        createButton.backgroundColor = viewModel.isFormValid ? .black : .ypGray
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addToView(scrollView)
        
        textFieldContainer.addToView(trackerNameTextField)
        textFieldContainer.addToView(characterCounterLabel)
        
        scrollView.addToView(completedDaysLabel)
        scrollView.addToView(textFieldContainer)
        scrollView.addToView(categoryAndScheduleTableView)
        scrollView.addToView(emojiAndColorCollectionView)
        scrollView.addToView(buttonsStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            completedDaysLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Constants.defaultSpacing),
            completedDaysLabel.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            
            textFieldContainer.topAnchor.constraint(equalTo: completedDaysLabel.bottomAnchor, constant: 40),
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
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigation() {
        title = Constants.titleNewHabit
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.updateName(textField.text ?? "")
    }
    
    @objc private func saveButtonTapped() {
        let updated = viewModel.buildUpdatedTracker()
        delegate?.updateTracker(updated, to: viewModel.selectedCategory)
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.loadTrackersFromCoreData()
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EditTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource
extension EditTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.selectedScheduleDays.isEmpty {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reusableIdentifier, for: indexPath) as? CategoryCell else {
                    return UITableViewCell()
                }
                cell.titleLabel.text = Constants.categoryTitle
                cell.descriptionLabel.text = viewModel.selectedCategory.isEmpty ? Constants.chooseOrCreate : viewModel.selectedCategory
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.reusableIdentifier, for: indexPath) as? ScheduleCell else {
                    return UITableViewCell()
                }
                cell.titleLabel.text = Constants.scheduleTitle
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reusableIdentifier, for: indexPath) as? CategoryCell else {
                return UITableViewCell()
            }
            if indexPath.row == 0 {
                cell.titleLabel.text = Constants.categoryTitle
                cell.descriptionLabel.text = viewModel.selectedCategory.isEmpty ? Constants.chooseOrCreate : viewModel.selectedCategory
                return cell
            } else {
                cell.titleLabel.text = Constants.scheduleTitle
                if viewModel.selectedScheduleDays.count == 7 {
                    cell.descriptionLabel.text = Constants.everyDay
                } else {
                    cell.descriptionLabel.text = viewModel.selectedScheduleDays
                        .map { $0.shortName }
                        .joined(separator: ", ")
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                }
                return cell
            }
        }
    }}

// MARK: - UITableViewDelegate
extension EditTrackerViewController: UITableViewDelegate {
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
            scheduleSelectViewController.selectedDays = Set(viewModel.selectedScheduleDays)
            present(UINavigationController(rootViewController: scheduleSelectViewController), animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension EditTrackerViewController: UICollectionViewDataSource {
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
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderTrackerEmojiColorSection.reuseIdentifier, for: indexPath) as? HeaderTrackerEmojiColorSection else {
            return UICollectionReusableView()
        }
        header.categoryTitle.text = indexPath.section == 0 ? "Эмодзи" : "Цвет"
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension EditTrackerViewController: UICollectionViewDelegate {
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
            
            self.viewModel.updateEmoji(self.emojis[indexPath.item])
            
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
            
          self.viewModel.updateColor(self.colors[indexPath.item])
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackerEmojiColorCell {
                UIView.animate(withDuration: Constants.animationDuration) {
                    cell.layer.borderColor = self.colors[indexPath.item].cgColor
                    cell.layer.borderWidth = Constants.colorBorderWidth
                    cell.layer.cornerRadius = Constants.colorCornerRadius
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackerEmojiColorCell {
                UIView.animate(withDuration: Constants.animationDuration) {
                    if indexPath.section == 0 {
                        cell.contentView.backgroundColor = .clear
                    } else {
                        cell.layer.borderWidth = 0
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EditTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constants.headerHeight)
    }
}

// MARK: - CategorySelectViewControllerDelegate

extension EditTrackerViewController: CategorySelectViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategoryCD) {
        let category = category.title ?? ""
        viewModel.updateCategory(category)
        DispatchQueue.main.async {
            self.categoryAndScheduleTableView.reloadData()
        }
    }
}

// MARK: - ScheduleSelectViewControllerDelegate

extension EditTrackerViewController: ScheduleSelectViewControllerDelegate {
    func didChooseSchedule(_ days: [WeekDay]) {
        viewModel.updateSchedule(days)
        DispatchQueue.main.async {
            self.categoryAndScheduleTableView.reloadData()
        }
    }
}
