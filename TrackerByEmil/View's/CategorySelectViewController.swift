import UIKit

protocol CategorySelectViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategoryCD)
}

final class CategorySelectViewController: UIViewController {
    
    weak var delegate: CategorySelectViewControllerDelegate?
    
    // MARK: - Layout Constants
    
    private enum Constants {
        // Layout
        static let cornerRadius: CGFloat = 16
        static let defaultSpacing: CGFloat = 16
        static let wideSpacing: CGFloat = 20
        static let buttonHeight: CGFloat = 60
        static let cellHeight: CGFloat = 75
        static let tableHeaderHeight: CGFloat = 1
        static let separatorInset: CGFloat = 16
        
        // Titles
        static let screenTitle = "Категории"
        static let addCategoryTitle = "Добавить категорию"
        static let doneTitle = "Готово"
        
        // Alert
        static let alertDeleteTitle = "Удаление категории"
        static let alertDeleteMessage = "Эта категория точно не нужна?"
        static let alertDeleteAction = "Удалить"
        static let alertCancelAction = "Отменить"
        
        // Errors
        static let errorTitle = "Ошибка"
        static let errorOkAction = "Ок"
    }
    
    // MARK: - Properties
    
    private let viewModel: CategorySelectViewModel
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.layer.cornerRadius = Constants.cornerRadius
        tv.separatorInset = UIEdgeInsets(
            top: 0,
            left: Constants.separatorInset,
            bottom: 0,
            right: Constants.separatorInset
        )
        tv.register(CategorySelectCell.self, forCellReuseIdentifier: CategorySelectCell.reuseIdentifier)
        tv.dataSource = self
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.tableHeaderView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 0,
            height: Constants.tableHeaderHeight
        ))
        return tv
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitle(Constants.addCategoryTitle, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    
    init(viewModel: CategorySelectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAppearance()
        setupNavigation()
        bindViewModel()
    }
    
    // MARK: - Setup UI 
    
    private func setupUI() {
        [tableView, actionButton].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.defaultSpacing),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.defaultSpacing),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.defaultSpacing),
            tableView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -Constants.defaultSpacing),
            
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.wideSpacing),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.wideSpacing),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.wideSpacing),
            actionButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    private func setupAppearance() {
        view.backgroundColor = .ypWhite
    }
    
    private func setupNavigation() {
        navigationItem.hidesBackButton = true
        title = Constants.screenTitle
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updateButtonState()
        }
        
        viewModel.onError = { [weak self] errorMessage in
            let alert = UIAlertController(title: Constants.errorTitle, message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.errorOkAction, style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func updateButtonState() {
        if viewModel.hasSelectedCategory {
            actionButton.setTitle(Constants.doneTitle, for: .normal)
        } else {
            actionButton.setTitle(Constants.addCategoryTitle, for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @objc private func actionButtonTapped() {
        if viewModel.hasSelectedCategory {
            if let selected = viewModel.selectedCategory {
                delegate?.didSelectCategory(selected)
            }
            navigationController?.popViewController(animated: true)
        } else {
            let createVC = EditCategoryViewController()
            createVC.onSave = { [weak self] newTitle in
                self?.viewModel.addCategory(title: newTitle)
            }
            present(UINavigationController(rootViewController: createVC), animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension CategorySelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategorySelectCell.reuseIdentifier,
            for: indexPath
        ) as? CategorySelectCell else {
            return UITableViewCell()
        }
        let cellVM = viewModel.cellViewModel(at: indexPath)
        cell.configure(with: cellVM)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfRows() - 1 {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: .greatestFiniteMagnitude
            )
        }
    }
}

extension CategorySelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
        updateButtonState()
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self = self else { return nil }

            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                let category = self.viewModel.categories[indexPath.row]
                let editVC = EditCategoryViewController()
                editVC.category = category
                editVC.onSave = { [weak self] newTitle in
                    self?.viewModel.updateCategory(at: indexPath, newTitle: newTitle)
                }
                self.present(UINavigationController(rootViewController: editVC), animated: true)
            }

            let delete = UIAction(title: Constants.alertDeleteAction,
                                  image: UIImage(systemName: "trash"),
                                  attributes: .destructive) { _ in
                let alert = UIAlertController(
                    title: Constants.alertDeleteTitle,
                    message: Constants.alertDeleteMessage,
                    preferredStyle: .actionSheet
                )
                
                alert.addAction(UIAlertAction(title: Constants.alertDeleteAction, style: .destructive, handler: { _ in
                    self.viewModel.deleteCategory(at: indexPath)
                }))
                
                alert.addAction(UIAlertAction(title: Constants.alertCancelAction, style: .cancel))
                
                self.present(alert, animated: true)
            }

            return UIMenu(title: "", children: [edit, delete])
        }
    }
}
