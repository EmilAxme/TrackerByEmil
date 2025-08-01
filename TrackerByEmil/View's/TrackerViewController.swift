//
//  MainScreenViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 01.06.2025.
//

import UIKit

final class TrackerViewController: UIViewController {

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
        return datePicker
    }()
    
    private lazy var trackerCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        let plusImage = UIImage(named: "plusImage")
        button.addTarget(self, action: #selector(addTrackerButtonAction), for: .touchUpInside)
        button.setImage(plusImage, for: .normal)
        return button
    }()
    
    private lazy var dateField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.text = dateFormatter.string(from: currentDate)
        textField.backgroundColor = UIColor(named: "dateColor")
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        textField.inputView = datePicker
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
        
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.searchTextField.textColor = .ypBlack
        
        return searchBar
    }()
    
    private lazy var labelAndSearchBarStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, trackerSearchBar])
        stackView.axis = .vertical
        stackView.spacing = 7
        return stackView
    }()

    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stubImage")
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
        stackView.spacing = 8
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
        let scalingFactor: CGFloat = 0.25
        let dynamicTopPadding = diagonal * scalingFactor
        
        NSLayoutConstraint.activate([
            stubImage.widthAnchor.constraint(equalToConstant: 80),
            
            stubStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stubStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stubStackView.heightAnchor.constraint(equalToConstant: 106),
            stubStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubStackView.topAnchor.constraint(equalTo: trackerSearchBar.bottomAnchor, constant: dynamicTopPadding),
            
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            
            dateField.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            dateField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dateField.widthAnchor.constraint(equalToConstant: 77),
            dateField.heightAnchor.constraint(equalToConstant: 34),
            
            labelAndSearchBarStackView.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1),
            labelAndSearchBarStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            labelAndSearchBarStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            trackerCollection.topAnchor.constraint(equalTo: labelAndSearchBarStackView.bottomAnchor, constant: 24),
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
        let hasTrackers = categories.contains { !$0.trackerOfCategory.isEmpty }
        stubStackView.isHidden = hasTrackers
    }
    
    // MARK: - Actions
    
    @objc private func addTrackerButtonAction() {
        showAddNewTrackerVC()
    }
    
    @objc private func tapDone() {
        getDateFromPicker()
        view.endEditing(true)
    }
    
    @objc private func getDateFromPicker() {
        currentDate = datePicker.date
        dateField.text = dateFormatter.string(from: currentDate)
    }
    
    // MARK: - Public Methods
    
    func addNewTracker(id: UUID, name: String, color: UIColor, emoji: String, categoryTitle: String) {
        let newTracker = Tracker(id: id, name: name, color: color, emoji: emoji)
        
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
        trackerCollection.reloadData()
        stubStackView.isHidden = true
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < categories.count else { return 0 }
        return categories[section].trackerOfCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomTrackerCell.reuseIdentifier, for: indexPath) as? CustomTrackerCell else {
            print("Не удалось создать CustomTrackerCell")
            return UICollectionViewCell()
        }
        
        let tracker = categories[indexPath.section].trackerOfCategory[indexPath.item]
        cell.configure(source: tracker)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = trackerCollection.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderOfTrackersSection.reuseIdentifier,
            for: indexPath
        ) as? HeaderOfTrackersSection else {
            print("Не удалось создать HeaderOfTrackersSection")
            return UICollectionReusableView()

        }
        
        header.categoryTitle.text = categories[indexPath.section].title
        return header
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 9
        let horizontalInset: CGFloat = 16
        let numberOfItemsInRow: CGFloat = 2

        let totalSpacing = (numberOfItemsInRow - 1) * spacing
        let totalInsets = horizontalInset * 2
        let availableWidth = collectionView.bounds.width - totalSpacing - totalInsets
        let itemWidth = availableWidth / numberOfItemsInRow
        let itemHeight = itemWidth * 0.8

        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                       point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        
        let indexPath = indexPaths[0]
        
        return UIContextMenuConfiguration(actionProvider: { action in
            return UIMenu(children: [
                UIAction(title: "Bold") { _ in },
                UIAction(title: "Italic") { _ in },
                UIAction(title: "Both") { _ in }
            ])
        })
    }
    
}
