//
//  EditCategoryViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 11.09.2025.
//

import UIKit

final class EditCategoryViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let textFieldTop: CGFloat = 40
        static let textFieldSideInset: CGFloat = 16
        static let textFieldHeight: CGFloat = 75
        
        static let buttonSideInset: CGFloat = 20
        static let buttonBottomInset: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        
        static let textFieldCornerRadius: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 16
        static let textFieldFontSize: CGFloat = 17
        static let buttonFontSize: CGFloat = 17
        static let leftPadding: CGFloat = 16
        
        static let textFieldPlaceholder = "Название категории"
        static let doneButtonTitle = "Готово"
        static let screenTitle = "Редактирование категории"
    }
    
    // MARK: - Properties
    var category: TrackerCategoryCD?
    var onSave: ((String) -> Void)?
    
    // MARK: - UI Elements
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.textFieldPlaceholder
        textField.backgroundColor = .ypBackground
        textField.text = category?.title
        textField.leftView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: Constants.leftPadding,
            height: textField.frame.height
        ))
        textField.leftViewMode = .always
        textField.font = .systemFont(ofSize: Constants.textFieldFontSize)
        textField.layer.cornerRadius = Constants.textFieldCornerRadius
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.doneButtonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .semibold)
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAppearance()
        textField.becomeFirstResponder()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        [
            textField,
            doneButton
        ].forEach {
            view.addToView($0)
        }
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.textFieldTop),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.textFieldSideInset),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.textFieldSideInset),
            textField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonSideInset),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonSideInset),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.buttonBottomInset),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
        title = Constants.screenTitle
    }
    
    // MARK: - Actions
    @objc private func doneTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        onSave?(text)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EditCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneTapped()
        return true
    }
}
