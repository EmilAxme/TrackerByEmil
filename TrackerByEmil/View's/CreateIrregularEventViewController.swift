//
//  CreateIrregularEventViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 13.07.2025.
//

import UIKit

final class CreateIrregularEventViewController: UIViewController {
    
    // MARK: - Layout Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let defaultSpacing: CGFloat = 24
        static let smallSpacing: CGFloat = 8
        static let textFieldHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let cellHeight: CGFloat = 75
        static let sidePadding: CGFloat = 16
        static let wideSidePadding: CGFloat = 20
        static let textFieldLeftPadding: CGFloat = 16
    }
    
    // MARK: - Properties
    private var allDays: [WeekDay] = [.friday, .saturday, .sunday, .monday, .tuesday, .wednesday, .thursday]
    var delegate: TrackerViewController?
    let mockUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    // MARK: - UI Elements
    
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
        return textField
    }()
    
    private lazy var categoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .ypGray
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reusableIdentifier)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
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
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
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
        setupUI()
        setupAppearance()
        setupNavigation()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        [trackerNameTextField,
         categoryTableView,
         buttonsStackView].forEach {
            view.addToView($0)
        }
        
        NSLayoutConstraint.activate([
            trackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.defaultSpacing),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sidePadding),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sidePadding),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            categoryTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: Constants.defaultSpacing),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sidePadding),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sidePadding),
            categoryTableView.heightAnchor.constraint(equalToConstant: Constants.cellHeight),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.wideSidePadding),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.wideSidePadding),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = .ypWhite
    }
    
    private func setupNavigation() {
        title = "Новое нерегулярное событие"
        navigationItem.hidesBackButton = true
    }
    
    private func updateCreateButtonState() {
        let isNameEntered = !(trackerNameTextField.text?.isEmpty ?? true)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.createButton.isEnabled = isNameEntered
            self.createButton.backgroundColor = isNameEntered ? .ypBlack : .ypGray
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            self.delegate?.addNewTracker(
                id: self.mockUUID,
                name: self.trackerNameTextField.text ?? "",
                color: .ypRed,
                emoji: "❤️",
                categoryTitle: "Важное",
                schedule: allDays
            )
            self.dismiss(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension CreateIrregularEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
}

// MARK: - UITableViewDataSource

extension CreateIrregularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reusableIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = "Категория"
        cell.descriptionLabel.text = "Важное"
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
}

// MARK: - UITableViewDelegate

extension CreateIrregularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.cellHeight
    }
}
