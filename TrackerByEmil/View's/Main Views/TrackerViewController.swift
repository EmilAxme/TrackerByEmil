//
//  MainScreenViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 01.06.2025.
//

import UIKit
import CoreData
import AppMetricaCore

final class TrackerViewController: UIViewController {
    
    // MARK: - Layout Constants
    
    private enum Constants {
        
        //Layout
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
        
        // Localize
        static let screenTitle = "trackers_title".localized
        static let searchPlaceholder = "search_placeholder".localized
        static let stubText = "stub_text".localized
        static let filterButton = "filter_button".localized
        static let nenahodText = "nenahod_text".localized
    }
    
    // MARK: - Properties
    private let statsStore = TrackerStatsStore()
    
    var coreDataStack: CoreDataStackProtocol?
    var trackerProvider: TrackerProviderProtocol?
    var trackerCategoryProvider: TrackerCategoryProviderProtocol?
    var trackerRecordProvider: TrackerRecordProviderProtocol?
    
    var categories: [TrackerCategory] = [] {
        didSet {
            updateStubVisibility()
            updateFilterButtonVisibility()
        }
    }
    
    var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private var selectedFilter: TrackerFilter = .all
    
    var currentDate = Date()

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    // MARK: - UI Elements
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "Blue")
        button.setTitle(Constants.filterButton, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = UIDatePickerStyle.compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = dateFormatter.string(from: currentDate)
        label.textColor = .black
        label.backgroundColor = .date
        label.layer.cornerRadius = Constants.cornerRadius
        label.clipsToBounds = true
        label.isUserInteractionEnabled = false
        return label
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.screenTitle
        label.textColor = .label
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var trackerSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = Constants.searchPlaceholder
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.layer.cornerRadius = Constants.smallCornerRadius
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.returnKeyType = .done
        searchBar.searchTextField.textColor = .ypBlack
        searchBar.delegate = self
        searchBar.searchTextField.enablesReturnKeyAutomatically = false
        searchBar.searchTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
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
        label.text = Constants.stubText
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
        setupDependenciesIfNeeded()
        setupCollectionView()
        setupUI()

        selectedFilter = FilterStorage().load()
        
        loadTrackersFromCoreData()
        loadCompletedTrackers()
        updateVisibleCategories()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.reportEvent(event: .open, screen: .main, item: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.shared.reportEvent(event: .close, screen: .main, item: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        trackerCollection.alwaysBounceVertical = true
        
        let bottomInset = filterButton.bounds.height + 16
        
        if trackerCollection.contentInset.bottom != bottomInset {
            trackerCollection.contentInset.bottom = bottomInset
            trackerCollection.scrollIndicatorInsets.bottom = bottomInset
        }
        
        view.bringSubviewToFront(filterButton)
    }
    
    // MARK: - Private Methods
    
    private func setupCollectionView() {
        trackerCollection.dataSource = self
        trackerCollection.delegate = self
        trackerCollection.register(CustomTrackerCell.self, forCellWithReuseIdentifier: CustomTrackerCell.reuseIdentifier)
        trackerCollection.register(HeaderOfTrackersSection.self,
                                   forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                   withReuseIdentifier: HeaderOfTrackersSection.reuseIdentifier)
    }
    
    private func setupDependenciesIfNeeded() {
        let coreDataStack = self.coreDataStack ?? CoreDataStack()
        let categoryStore = TrackerCategoryStore(context: coreDataStack.context)
        self.coreDataStack = coreDataStack
        
        trackerProvider = trackerProvider ?? TrackerProvider(coreDataStack: coreDataStack)
        trackerCategoryProvider = trackerCategoryProvider ?? TrackerCategoryProvider(store: categoryStore)
        trackerRecordProvider = trackerRecordProvider ?? TrackerRecordProvider(coreDataStack: coreDataStack)
        
        (trackerProvider as? TrackerProvider)?.delegate = self
        (trackerCategoryProvider as? TrackerCategoryProvider)?.delegate = self
        (trackerRecordProvider as? TrackerRecordProvider)?.delegate = self
    }
    
    private func setupUI() {
        [filterButton,
         labelAndSearchBarStackView,
         trackerCollection,
         datePicker,
         dateLabel,
         stubStackView,
         addTrackerButton
        ].forEach {
            view.addToView($0)
        }
        
        view.bringSubviewToFront(filterButton)
        
        let screenSize = UIScreen.main.bounds.size
        let diagonal = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2))
        let dynamicTopPadding = diagonal * Constants.scalingFactor
        
        NSLayoutConstraint.activate([
            stubImage.widthAnchor.constraint(equalToConstant: Constants.stubImageSize),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            stubStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stubStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stubStackView.heightAnchor.constraint(equalToConstant: Constants.stubStackHeight),
            stubStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubStackView.topAnchor.constraint(equalTo: trackerSearchBar.bottomAnchor, constant: dynamicTopPadding),
            
            addTrackerButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            addTrackerButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.buttonLeadingPadding),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.buttonTopPadding),
            
            dateLabel.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.dateTrailingPadding),
            dateLabel.widthAnchor.constraint(equalToConstant: Constants.dateFieldWidth),
            dateLabel.heightAnchor.constraint(equalToConstant: Constants.dateFieldHeight),
            
            datePicker.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.dateTrailingPadding),
            datePicker.widthAnchor.constraint(equalToConstant: Constants.dateFieldWidth),
            datePicker.heightAnchor.constraint(equalToConstant: Constants.dateFieldHeight),
            
            labelAndSearchBarStackView.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: Constants.buttonTopPadding),
            labelAndSearchBarStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalInset),
            labelAndSearchBarStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalInset),
            
            trackerCollection.topAnchor.constraint(equalTo: labelAndSearchBarStackView.bottomAnchor, constant: Constants.collectionTopPadding),
            trackerCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trackerCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func convertToTracker(trackerCD: TrackerCD) -> Tracker? {
        guard let id = trackerCD.id,
              let name = trackerCD.name,
              let emoji = trackerCD.emoji,
              let colorHex = trackerCD.color,
              let weekDays = trackerCD.schedule else {
            return nil
        }
        
        let color = UIColorMarshalling.color(from: colorHex)
        let schedule = weekDays.toWeekDays()
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    private func showAddNewTrackerVC() {
        let secondVC = AddTrackerViewController()
        secondVC.delegate = self
        let navController = UINavigationController(rootViewController: secondVC)
        present(navController, animated: true)
    }
    
    private func updateStubVisibility() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.stubStackView.isHidden = !self.visibleCategories.isEmpty
        }
    }
    
    private func updateDateField() {
        currentDate = datePicker.date
        dateLabel.text = dateFormatter.string(from: currentDate)
    }
    
    private func updateVisibleCategories() {
        let calendar = Calendar.current
        let filteredWeekDay = calendar.component(.weekday, from: datePicker.date)
        
        visibleCategories = categories.compactMap { category in
            // Фильтруем только трекеры по выбранному дню недели
            let trackersForDay = category.trackerOfCategory.filter { tracker in
                tracker.schedule.contains { $0.rawValue == filteredWeekDay }
            }
            if trackersForDay.isEmpty { return nil }
            
            // Используем существующий title категории
            return TrackerCategory(title: category.title, trackerOfCategory: trackersForDay)
        }
        
        updateStubVisibility()
        updateDateField()
        trackerCollection.reloadData()
    }
    
    private func updateLocalCategories(with newTracker: Tracker, categoryTitle: String) {
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
    }
    
    private func fetchOrCreateCategory(title: String) throws -> TrackerCategoryCD {
        guard let coreDataStack else {
            throw NSError(domain: "TrackerError", code: 0, userInfo: [NSLocalizedDescriptionKey: "CoreDataStack отсутствует"])
        }
        
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let existing = try coreDataStack.context.fetch(request).first {
            return existing
        } else {
            let newCategory = TrackerCategory(title: title, trackerOfCategory: [])
            let store = TrackerCategoryStore(context: coreDataStack.context)
            try store.addCategory(newCategory)
            return try coreDataStack.context.fetch(request).first
                ?? { throw NSError(domain: "TrackerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Не удалось создать категорию"]) }()
        }
    }
    
    private func loadCompletedTrackers() {
        guard let trackerRecordProvider else { return }
        completedTrackers = trackerRecordProvider.fetchAllRecords()
    }
    
    private func nullSearchStub() {
        let trackersToday = hasTrackerForDay()
        
        let showNenahod = (selectedFilter == .completed || selectedFilter == .uncompleted || selectedFilter == .today) && trackersToday
        stubLabel.text = showNenahod ? Constants.nenahodText : Constants.stubText
        stubImage.image = UIImage(resource: showNenahod ? .nenahod : .stub)
    }
    
    private func updateFilterButtonVisibility() {
        filterButton.isHidden = !hasTrackerForDay()
    }
    
    private func hasTrackerForDay() -> Bool {
        let calendar = Calendar.current
        let targetDate = datePicker.date
        let weekday = calendar.component(.weekday, from: targetDate)
        
        return categories.contains { category in
            category.trackerOfCategory.contains { tracker in
                tracker.schedule.contains { $0.rawValue == weekday }
            }
        }
    }
    
    private func applyFilter() {
        let calendar = Calendar.current
        var targetDate = datePicker.date
        let weekday = calendar.component(.weekday, from: targetDate)
        
        switch selectedFilter {
        case .all:
            visibleCategories = categories.compactMap { category in
                let trackersForDay = category.trackerOfCategory.filter { tracker in
                    tracker.schedule.contains { $0.rawValue == weekday }
                }
                return trackersForDay.isEmpty ? nil : TrackerCategory(title: category.title, trackerOfCategory: trackersForDay)
            }
            
        case .today:
            targetDate = Date()
            datePicker.date = targetDate
            updateDateField()
            
            let todayWeekday = calendar.component(.weekday, from: targetDate)
            visibleCategories = categories.compactMap { category in
                let trackersForDay = category.trackerOfCategory.filter { tracker in
                    tracker.schedule.contains { $0.rawValue == todayWeekday }
                }
                return trackersForDay.isEmpty ? nil : TrackerCategory(title: category.title, trackerOfCategory: trackersForDay)
            }
            
        case .completed:
            visibleCategories = categories.compactMap { category in
                let trackersForDay = category.trackerOfCategory.filter { tracker in
                    tracker.schedule.contains { $0.rawValue == weekday } &&
                    completedTrackers.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: targetDate) }
                }
                return trackersForDay.isEmpty ? nil : TrackerCategory(title: category.title, trackerOfCategory: trackersForDay)
            }
            
        case .uncompleted:
            visibleCategories = categories.compactMap { category in
                let trackersForDay = category.trackerOfCategory.filter { tracker in
                    tracker.schedule.contains { $0.rawValue == weekday } &&
                    !completedTrackers.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: targetDate) }
                }
                return trackersForDay.isEmpty ? nil : TrackerCategory(title: category.title, trackerOfCategory: trackersForDay)
            }
        }
        
        if visibleCategories.isEmpty {
            updateStubVisibility()
            nullSearchStub()
        } else {
            updateStubVisibility()
        }
        
        trackerCollection.reloadData()
    }
    // MARK: - Actions
    
    @objc private func addTrackerButtonAction() {
        AnalyticsService.shared.reportEvent(event: .click, screen: .main, item: .addTrack)
        showAddNewTrackerVC()
    }
    
    @objc private func dateChanged() {
        trackerSearchBar.text = ""
        textDidChange(trackerSearchBar.searchTextField)
        updateVisibleCategories()
        updateFilterButtonVisibility()
        if selectedFilter != .today {
            applyFilter()
        }
        print(selectedFilter)
    }
    
    @objc func textDidChange(_ searchField: UISearchTextField) {
        let calendar = Calendar.current
        let filteredWeekDay = calendar.component(.weekday, from: datePicker.date)
        
        var filteredCategories = categories.compactMap { category -> TrackerCategory? in
            let trackersForDay = category.trackerOfCategory.filter { tracker in
                tracker.schedule.contains { $0.rawValue == filteredWeekDay }
            }
            return trackersForDay.isEmpty ? nil : TrackerCategory(title: category.title,
                                                                  trackerOfCategory: trackersForDay)
        }
        
        if let searchText = searchField.text, !searchText.isEmpty {
            filteredCategories = filteredCategories.compactMap { category -> TrackerCategory? in
                let filteredTrackers = category.trackerOfCategory.filter {
                    $0.name.lowercased().contains(searchText.lowercased())
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title,
                                                                        trackerOfCategory: filteredTrackers)
            }
        }
        
        visibleCategories = filteredCategories
        
        if visibleCategories.isEmpty {
            stubStackView.isHidden = false
            if let searchText = searchField.text, !searchText.isEmpty {
                stubLabel.text = Constants.nenahodText
                stubImage.image = UIImage(resource: .nenahod)
            } else {
                stubLabel.text = Constants.stubText
                stubImage.image = UIImage(resource: .stub)
            }
        } else {
            stubStackView.isHidden = true
        }
        
        trackerCollection.reloadData()
    }
    
    @objc private func filterTapped() {
        AnalyticsService.shared.reportEvent(event: .click, screen: .main, item: .filter)
        let filterVC = FilterViewController(selectedFilter: selectedFilter)
        filterVC.onFilterSelected = { [weak self] filter in
            guard let self else { return }
            self.selectedFilter = filter
            self.applyFilter()
        }
        let nav = UINavigationController(rootViewController: filterVC)
        present(nav, animated: true)
    }
    
    // MARK: - Public Methods
    
    func updateTracker(_ updated: Tracker, to categoryTitle: String) {
        guard let trackerProvider else {
            assertionFailure("TrackerProvider is not initialized")
            return
        }

        do {
            let category = try fetchOrCreateCategory(title: categoryTitle)
            try trackerProvider.updateTracker(updated, to: category)
            loadTrackersFromCoreData()
            updateVisibleCategories()
        } catch {
            print("Ошибка при обновлении трекера: \(error)")
        }
        applyFilter()
    }
    
    func addNewTracker(_ tracker: Tracker, to categoryTitle: String) {
        guard let trackerProvider else {
            assertionFailure("Dependencies are not initialized")
            return
        }
        
        do {
            let category = try fetchOrCreateCategory(title: categoryTitle)
            try trackerProvider.addTracker(tracker, to: category)
        
            updateLocalCategories(with: tracker, categoryTitle: categoryTitle)
            
            updateVisibleCategories()
            
        } catch {
            print("Ошибка при сохранении трекера: \(error)")
        }
        applyFilter()
    }
    
    func loadTrackersFromCoreData() {
        guard let trackerProvider = trackerProvider else { return }

        var categoriesDict: [String: [Tracker]] = [:]

        for section in 0..<trackerProvider.numberOfSections {
            for row in 0..<trackerProvider.numberOfRowsInSection(section) {
                let indexPath = IndexPath(row: row, section: section)
                if let trackerCD = trackerProvider.object(at: indexPath),
                   let tracker = convertToTracker(trackerCD: trackerCD),
                   let categoryTitle = trackerCD.category?.title {
                    
                    categoriesDict[categoryTitle, default: []].append(tracker)
                }
            }
        }

        categories = categoriesDict.map { TrackerCategory(title: $0.key, trackerOfCategory: $0.value) }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackerOfCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomTrackerCell.reuseIdentifier, for: indexPath) as? CustomTrackerCell else {
            return UICollectionViewCell()
        }
        
        
        
        let isFutureDate = datePicker.date > Date()
        
        let tracker = visibleCategories[indexPath.section].trackerOfCategory[indexPath.item]
        
        let isCompletedToday = completedTrackers.contains {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        let daysCount = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell.configure(source: tracker, isCompleted: isCompletedToday, dayCount: daysCount)
        cell.isFuture(isActive: !isFutureDate)
        
        cell.onDoneButtonTapped = { [weak self] trackerId, isCompleted in
            guard let self else { return }
            let record = TrackerRecord(id: trackerId, date: self.currentDate)
            
            AnalyticsService.shared.reportEvent(event: .click, screen: .main, item: .track)
            
            do {
                if isCompleted {
                    try self.trackerRecordProvider?.addRecord(record)
                    self.statsStore.addCompleted()
                } else {
                    try self.trackerRecordProvider?.removeRecord(record)
                    self.statsStore.removeCompleted()
                }
            } catch {
                print("Ошибка при изменении записи: \(error)")
            }
        }
        
        cell.onEditTapped = { [weak self] in
            guard let self else { return }
            AnalyticsService.shared.reportEvent(event: .click, screen: .main, item: .edit)
            
            let categoryTitle = self.visibleCategories[indexPath.section].title
            let completedDays = self.completedTrackers.filter { $0.id == tracker.id }.count
            
            let editViewModel = EditTrackerViewModel(
                tracker: tracker,
                category: categoryTitle,
                completedDays: completedDays
            )
            let editVC = EditTrackerViewController(viewModel: editViewModel)
            editVC.delegate = self
            
            let navController = UINavigationController(rootViewController: editVC)
            self.present(navController, animated: true)
        }
        
        // 👇 Удалить
        cell.onDeleteTapped = { [weak self] in
            guard let self else { return }
            AnalyticsService.shared.reportEvent(event: .click, screen: .main, item: .delete)
            
            let alert = UIAlertController(
                title: "Удалить",
                message: "Уверены что хотите удалить трекер?",
                preferredStyle: .actionSheet
            )
            
            alert.addAction(UIAlertAction(
                title: "Удалить",
                style: .destructive,
                handler: { _ in
                    do {
                        try self.trackerProvider?.deleteTracker(tracker)
                        self.loadTrackersFromCoreData()
                        self.updateVisibleCategories()
                    } catch {
                        print("Ошибка при удалении трекера: \(error)")
                    }
                }
            ))
            
            alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
            self.present(alert, animated: true)
        }
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
        
        let titleCategory = visibleCategories[indexPath.section].title
        
        header.categoryTitle.text = titleCategory
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
}

// MARK: - UISearchBarDelegate

extension TrackerViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - TrackerProviderDelegate

extension TrackerViewController: TrackerProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        DispatchQueue.main.async { [weak self] in
            self?.loadTrackersFromCoreData()
        }
    }
}

// MARK: - TrackerCategoryProviderDelegate
extension TrackerViewController: TrackerCategoryProviderDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        DispatchQueue.main.async { [weak self] in
            self?.loadTrackersFromCoreData()
        }
    }
}

// MARK: - TrackerRecordProviderDelegate
extension TrackerViewController: TrackerRecordProviderDelegate {
    func didUpdate(_ update: TrackerRecordStoreUpdate) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.completedTrackers = self.trackerRecordProvider?.fetchAllRecords() ?? []
            self.trackerCollection.reloadData()
        }
    }
}
