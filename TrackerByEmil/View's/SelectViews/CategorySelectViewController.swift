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
        static let maxTableHeight: CGFloat = 525
        static let stubSpacing: CGFloat = 8
        static let stubImageSize: CGFloat = 80
        static let stubStackHeight: CGFloat = 106
        
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
        tableView.register(CategorySelectCell.self, forCellReuseIdentifier: CategorySelectCell.reuseIdentifier)
        tableView.tableHeaderView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 0,
            height: Constants.tableHeaderHeight
        ))
        return tableView
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitle(Constants.addCategoryTitle, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .stub)
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу?"
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
    
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
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
        updateTableViewHeight()
        updateStubVisibility()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        [tableView, actionButton, stubStackView].forEach { view.addToView($0) }
        updateStubVisibility()

        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            stubImage.widthAnchor.constraint(equalToConstant: Constants.stubImageSize),
            
            stubStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.defaultSpacing),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.defaultSpacing),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.defaultSpacing),
            tableViewHeightConstraint,
            
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
            guard let self else { return }
            self.tableView.reloadData()
            self.updateButtonState()
            self.updateTableViewHeight()
            self.updateStubVisibility() 
        }
        
        viewModel.onError = { [weak self] errorMessage in
            let alert = UIAlertController(title: Constants.errorTitle, message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.errorOkAction, style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func updateTableViewHeight() {
        let numberOfRows = viewModel.numberOfRows()
        let totalHeight = CGFloat(numberOfRows) * Constants.cellHeight

        let newHeight = min(totalHeight, Constants.maxTableHeight)
        tableViewHeightConstraint.constant = newHeight
        
        tableView.isScrollEnabled = totalHeight > Constants.maxTableHeight

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateButtonState() {
        if viewModel.hasSelectedCategory {
            actionButton.setTitle(Constants.doneTitle, for: .normal)
        } else {
            actionButton.setTitle(Constants.addCategoryTitle, for: .normal)
        }
    }
    
    private func updateStubVisibility() {
        let isEmpty = viewModel.categories.isEmpty
        stubStackView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func actionButtonTapped() {
        if viewModel.hasSelectedCategory {
            if let selected = viewModel.selectedCategory {
                delegate?.didSelectCategory(selected)
            }
            dismiss(animated: true)
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
}

extension CategorySelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath)
        updateButtonState()
        tableView.deselectRow(at: indexPath, animated: true)
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
                    self?.updateStubVisibility()
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
                    self.updateStubVisibility()
                }))
                
                alert.addAction(UIAlertAction(title: Constants.alertCancelAction, style: .cancel))
                
                self.present(alert, animated: true)
            }

            return UIMenu(title: "", children: [edit, delete])
        }
    }
}
