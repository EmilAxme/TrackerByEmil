//
//  CategoryChooseViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 16.06.2025.
//

import UIKit

// MARK: - Enum
enum WeekDay: Int, CaseIterable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    var fullName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

final class ScheduleSelectViewController: UIViewController {
    
    // MARK: - Properties
    var delegate: CreateTrackerViewController?
    var selectedDays: Set<WeekDay> = []
    
    //MARK: - UI Element's
    private lazy var weekTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DaysSelectCell.self, forCellReuseIdentifier: DaysSelectCell.reusableIdentifier)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        return tableView
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitle("Готово", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        guard let title = button.titleLabel else { return button }
        title.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAppearance()
        setupNavigation()
    }
    
    // MARK: - Private function's
    private func setupUI() {
        
        [weekTableView,
         readyButton].forEach {
            view.addToView($0)
        }
        
        NSLayoutConstraint.activate([
            weekTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            weekTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            weekTableView.heightAnchor.constraint(equalToConstant: CGFloat(WeekDay.allCases.count * 75)),
            weekTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = .ypWhite
    }
    
    private func setupNavigation() {
        navigationItem.hidesBackButton = true
        title = "Расписание"
    }
    
    // MARK: - Actions
    @objc private func readyButtonTapped() {
        let selected = Array(selectedDays).sorted(by: { $0.rawValue < $1.rawValue })
        
        guard
            let delegate,
            let navigationController
        else { return }
        
        delegate.didChooseSchedule(selected)
        
        navigationController.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleSelectViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DaysSelectCell.reusableIdentifier, for: indexPath) as? DaysSelectCell else {
            return UITableViewCell()
        }
        let day = WeekDay.allCases[indexPath.row]
        cell.configure(
            with: day,
            isOn: selectedDays.contains(day)
        ) { [weak self] isOn in
            guard let self else { return }
            if isOn {
                self.selectedDays.insert(day)
            } else {
                self.selectedDays.remove(day)
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == WeekDay.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
    }
}
