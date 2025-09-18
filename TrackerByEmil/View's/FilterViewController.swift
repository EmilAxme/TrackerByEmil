//
//  FilterViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 18.09.2025.
//

import UIKit

enum TrackerFilter: Equatable {
    case all
    case today
    case completed
    case uncompleted
}

final class FilterViewController: UIViewController {
    
    private let filters: [TrackerFilter] = [.all, .today, .completed, .uncompleted]
    private var selectedFilter: TrackerFilter
    var onFilterSelected: ((TrackerFilter) -> Void)?
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    // MARK: - Init
    
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func configureUI() {
        title = "Фильтры"
        view.backgroundColor = .ypWhite
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filter = filters[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .ypBackground
        
        switch filter {
        case .all:
            cell.textLabel?.text = "Все трекеры"
        case .today:
            cell.textLabel?.text = "Трекеры на сегодня"
        case .completed:
            cell.textLabel?.text = "Завершённые"
        case .uncompleted:
            cell.textLabel?.text = "Незавершённые"
        }
        
        // Правила отображения галочки
        if (filter == .completed || filter == .uncompleted) && filter == selectedFilter {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenFilter = filters[indexPath.row]
        onFilterSelected?(chosenFilter)
        dismiss(animated: true)
    }
}
