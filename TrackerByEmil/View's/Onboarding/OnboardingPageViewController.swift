//
//  OnboardingPageViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 13.09.2025.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    private enum Constants {
        static let defaultSpacing: CGFloat = 16
        static let titleHeight: CGFloat = 76
        static let titleBottomSpacing: CGFloat = 304
    }
    
    private let pageModel: OnboardingPageModel
    
    // MARK: - Init
    init(pageModel: OnboardingPageModel) {
        self.pageModel = pageModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = pageModel.text
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: pageModel.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Layout
    private func setupUI() {
        [backgroundImageView, welcomeLabel].forEach { view.addToView($0) }
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            welcomeLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -Constants.titleBottomSpacing),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                  constant: Constants.defaultSpacing),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                   constant: -Constants.defaultSpacing)
        ])
    }
}
