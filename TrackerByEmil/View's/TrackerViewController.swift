//
//  MainScreenViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 01.06.2025.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - Layout Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let smallCornerRadius: CGFloat = 10
        static let dateFieldWidth: CGFloat = 77
        static let dateFieldHeight: CGFloat = 34
        static let buttonSize: CGFloat = 42
        static let buttonTopPadding: CGFloat = 1
        static let buttonLeadingPadding: CGFloat = 6
        static let dateTrailingPadding: CGFloat = 16
        static let stackViewSpacing: CGFloat = 7
        static let stubSpacing: CGFloat = 8
        static let stubImageSize: CGFloat = 80
        static let stubStackHeight: CGFloat = 106
        static let collectionTopPadding: CGFloat = 24
        static let scalingFactor: CGFloat = 0.25
        static let itemAspectRatio: CGFloat = 0.8
        static let headerHeight: CGFloat = 50
        static let headerWidth: CGFloat = 50
        static let sectionSpacing: CGFloat = 9
        static let horizontalInset: CGFloat = 16
        static let itemsInRow: CGFloat = 2
    }
    
    // MARK: - Properties
    
    var categories: [TrackerCategory] = [] {
        didSet {
            updateStubVisibility()
        }
    }
    var completedTrackers: [TrackerRecord] = []
    var currentDate = Date()
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    // MARK: - UI Elements
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var trackerCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        let plusImage = UIImage(resource: .plus)
        button.addTarget(self, action: #selector(addTrackerButtonAction), for: .touchUpInside)
        button.setImage(plusImage, for: .normal)
        return button
    }()
    
    private lazy var dateField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.text = dateFormatter.string(from: currentDate)
        textField.backgroundColor = UIColor(named: "dateColor")
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.clipsToBounds = true
        textField.inputView = datePicker
        textField.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
        textField.addGestureRecognizer(tapGesture)
        return textField
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .label
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var trackerSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.layer.cornerRadius = Constants.smallCornerRadius
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.searchTextField.textColor = .ypBlack
        return searchBar
    }()
    
    private lazy var labelAndSearchBarStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, trackerSearchBar])
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()
    
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .stub)
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private lazy var stubStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stubImage, stubLabel])
        stackView.axis = .vertical
        stackView.spacing = Constants.stubSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = Date()
        
        trackerCollection.dataSource = self
        trackerCollection.delegate = self
        trackerCollection.register(CustomTrackerCell.self, forCellWithReuseIdentifier: CustomTrackerCell.reuseIdentifier)
        trackerCollection.register(HeaderOfTrackersSection.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderOfTrackersSection.reuseIdentifier)
        
        setupUI()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDone))
        view.addGestureRecognizer(tapGesture)
        
        [labelAndSearchBarStackView,
         trackerCollection,
         dateField,
         stubStackView,
         addTrackerButton
        ].forEach {
            view.addToView($0)
        }
        
        let screenSize = UIScreen.main.bounds.size
        let diagonal = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2))
        let dynamicTopPadding = diagonal * Constants.scalingFactor
        
        NSLayoutConstraint.activate([
            stubImage.widthAnchor.constraint(equalToConstant: Constants.stubImageSize),
            
            stubStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stubStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stubStackView.heightAnchor.constraint(equalToConstant: Constants.stubStackHeight),
            stubStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubStackView.topAnchor.constraint(equalTo: trackerSearchBar.bottomAnchor, constant: dynamicTopPadding),
            
            addTrackerButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            addTrackerButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.buttonLeadingPadding),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.buttonTopPadding),
            
            dateField.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            dateField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.dateTrailingPadding),
            dateField.widthAnchor.constraint(equalToConstant: Constants.dateFieldWidth),
            dateField.heightAnchor.constraint(equalToConstant: Constants.dateFieldHeight),
            
            labelAndSearchBarStackView.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: Constants.buttonTopPadding),
            labelAndSearchBarStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalInset),
            labelAndSearchBarStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalInset),
            
            trackerCollection.topAnchor.constraint(equalTo: labelAndSearchBarStackView.bottomAnchor, constant: Constants.collectionTopPadding),
            trackerCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trackerCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func commitCompletedTracker(id: UUID) {
        let trackerRecord = TrackerRecord(id: id, date: Date())
        completedTrackers.append(trackerRecord)
    }
    
    private func removeCompletedTracker(id: UUID) {
        if let index = completedTrackers.firstIndex(where: { $0.id == id }) {
            completedTrackers.remove(at: index)
        }
    }
    
    private func showAddNewTrackerVC() {
        let secondVC = AddTrackerViewController()
        secondVC.delegate = self
        let navController = UINavigationController(rootViewController: secondVC)
        present(navController, animated: true)
    }
    
    private func updateStubVisibility() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        
        let hasVisibleTrackers = categories.contains { category in
            category.trackerOfCategory.contains { tracker in
                tracker.schedule.contains { $0.rawValue == weekday }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.stubStackView.isHidden = hasVisibleTrackers
        }
    }
    
    // MARK: - Actions
    
    @objc private func addTrackerButtonAction() {
        showAddNewTrackerVC()
    }
    
    @objc private func tapDone() {
        getDateFromPicker()
        view.endEditing(true)
    }
    
    @objc private func showDatePicker() {
        dateField.becomeFirstResponder()
    }
    
    @objc private func datePickerValueChanged() {
        getDateFromPicker()
    }
    
    @objc private func getDateFromPicker() {
        currentDate = datePicker.date
        dateField.text = dateFormatter.string(from: currentDate)
        trackerCollection.reloadData()
        updateStubVisibility()
        dateField.resignFirstResponder()
    }
    
    // MARK: - Public Methods
    
    func addNewTracker(id: UUID, name: String, color: UIColor, emoji: String, categoryTitle: String, schedule: [WeekDay]) {
        let newTracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
        
        var newCategories: [TrackerCategory] = []
        var categoryWasUpdated = false
        
        for category in categories {
            if category.title == categoryTitle {
                let updatedTrackers = category.trackerOfCategory + [newTracker]
                let updatedCategory = TrackerCategory(title: category.title, trackerOfCategory: updatedTrackers)
                newCategories.append(updatedCategory)
                categoryWasUpdated = true
            } else {
                newCategories.append(category)
            }
        }
        
        if !categoryWasUpdated {
            let newCategory = TrackerCategory(title: categoryTitle, trackerOfCategory: [newTracker])
            newCategories.append(newCategory)
        }
        
        categories = newCategories
        DispatchQueue.main.async {
            self.trackerCollection.reloadData()
            self.stubStackView.isHidden = true
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < categories.count else { return 0 }
        
        let filteredTrackers = categories[section].trackerOfCategory.filter { tracker in
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: currentDate)
            return tracker.schedule.contains { $0.rawValue == weekday }
        }
        
        return filteredTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomTrackerCell.reuseIdentifier, for: indexPath) as? CustomTrackerCell else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.section]
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        
        let filteredTrackers = category.trackerOfCategory.filter { $0.schedule.contains { $0.rawValue == weekday } }
        
        guard indexPath.item < filteredTrackers.count else { return cell }
        let tracker = filteredTrackers[indexPath.item]
        cell.configure(source: tracker)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderOfTrackersSection.reuseIdentifier,
            for: indexPath
        ) as? HeaderOfTrackersSection else {
            return UICollectionReusableView()
        }
        
        let category = categories[indexPath.section]
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        
        let hasVisibleTrackers = category.trackerOfCategory.contains { tracker in
            tracker.schedule.contains { $0.rawValue == weekday }
        }
        
        header.categoryTitle.text = hasVisibleTrackers ? category.title : nil
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = (Constants.itemsInRow - 1) * Constants.sectionSpacing
        let totalInsets = Constants.horizontalInset * 2
        let availableWidth = collectionView.bounds.width - totalSpacing - totalInsets
        let itemWidth = availableWidth / Constants.itemsInRow
        let itemHeight = itemWidth * Constants.itemAspectRatio
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.sectionSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: Constants.headerWidth, height: Constants.headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        
        return UIContextMenuConfiguration(actionProvider: { action in
            return UIMenu(children: [
                UIAction(title: "Bold") { _ in },
                UIAction(title: "Italic") { _ in },
                UIAction(title: "Both") { _ in }
            ])
        })
    }
}
