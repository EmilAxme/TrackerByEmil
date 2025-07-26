//
//  AddTrackerViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 15.06.2025.
//
import UIKit

final class AddTrackerViewController: UIViewController {
    var delegate: TrackerViewController?
    private lazy var addHabitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(named: "Black")
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = UIColor(named: "White")
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addHabitButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(named: "Black")
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = UIColor(named: "White")
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addIrregularEventButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addHabitButton, addTrackerButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAppearance()
        setupNavigation()
    }
    
    private func setupUI() {
        
        view.addToView(buttonsStackView)
        
        NSLayoutConstraint.activate([
            addHabitButton.heightAnchor.constraint(equalToConstant: 60),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 60),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigation() {
        title = "Создание трекера"
    }
    
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
