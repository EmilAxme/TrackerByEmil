//
//  AddTrackerViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 15.06.2025.
//

import UIKit

final class AddTrackerViewController: UIViewController {
    
    // MARK: - Layout Constants
    
    private enum Constants {
        // UI
        static let buttonHeight: CGFloat = 60
        static let horizontalInset: CGFloat = 20
        static let stackSpacing: CGFloat = 16
        
        // Localized strings
        static let habitButtonTitle = "habit_button_title".localized
        static let irregularEventButtonTitle = "irregular_event_button_title".localized
        static let screenTitle = "add_tracker_screen_title".localized
    }
    
    // MARK: - Properties
    
    var delegate: TrackerViewController?
    
    // MARK: - UI Elements
    
    private lazy var addHabitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(named: "Black")
        button.setTitle(Constants.habitButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = UIColor(named: "White")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addHabitButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var addIrregularEventButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(named: "Black")
        button.setTitle(Constants.irregularEventButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = UIColor(named: "White")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addIrregularEventButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addHabitButton, addIrregularEventButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.stackSpacing
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
        view.addToView(buttonsStackView)
        
        NSLayoutConstraint.activate([
            addHabitButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            addIrregularEventButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalInset),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalInset),
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigation() {
        title = Constants.screenTitle
    }
    
    // MARK: - Actions
    
    @objc private func addHabitButtonAction() {
        let habitVC = CreateTrackerViewController()
        habitVC.delegate = delegate
        navigationController?.pushViewController(habitVC, animated: true)
    }
    
    @objc private func addIrregularEventButtonAction() {
        let eventVC = CreateIrregularEventViewController()
        eventVC.delegate = delegate
        navigationController?.pushViewController(eventVC, animated: true)
    }
}
