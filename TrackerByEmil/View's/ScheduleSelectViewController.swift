//
//  CategoryChooseViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 16.06.2025.
//

import UIKit

final class ScheduleSelectViewController: UIViewController {
    
    // MARK: - Layout Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let defaultSpacing: CGFloat = 16
        static let wideSpacing: CGFloat = 20
        static let buttonHeight: CGFloat = 60
        static let cellHeight: CGFloat = 75
        static let tableHeaderHeight: CGFloat = 1
        static let separatorInset: CGFloat = 16
    }
    
    // MARK: - Properties
    
    var delegate: CreateTrackerViewController?
    var selectedDays: Set<WeekDay> = []
    
    //MARK: - UI Element's
    
    private lazy var weekTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: Constants.separatorInset,
            bottom: 0,
            right: Constants.separatorInset
        )
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DaysSelectCell.self, forCellReuseIdentifier: DaysSelectCell.reusableIdentifier)
        tableView.tableHeaderView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 0,
            height: Constants.tableHeaderHeight
        ))
        return tableView
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitle("Готово", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
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
        [weekTableView, readyButton].forEach {
            view.addToView($0)
        }
        
        NSLayoutConstraint.activate([
            weekTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.defaultSpacing),
            weekTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.defaultSpacing),
            weekTableView.heightAnchor.constraint(equalToConstant: CGFloat(WeekDay.allCases.count) * Constants.cellHeight),
            weekTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.defaultSpacing),
            
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.wideSpacing),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.wideSpacing),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.wideSpacing),
            readyButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
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
        
        guard let delegate, let navigationController else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            delegate.didChooseSchedule(selected)
            navigationController.popViewController(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension ScheduleSelectViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DaysSelectCell.reusableIdentifier,
            for: indexPath
        ) as? DaysSelectCell else {
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
        return Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == WeekDay.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: .greatestFiniteMagnitude
            )
        }
    }
}
