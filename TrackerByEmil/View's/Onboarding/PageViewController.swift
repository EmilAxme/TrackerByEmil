//
//  OnboardingViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 10.09.2025.
//

import UIKit

class PageViewController: UIPageViewController {
    
    // MARK: - Layout Constants
    private enum Constants {
        static let buttonCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let buttonSpacing: CGFloat = 16
        static let buttonBottomInset: CGFloat = 50
        static let pageControlSpacing: CGFloat = 24
    }
    // MARK: - Closure
    var onFinish: (() -> Void)?
    
    // MARK: - UI Elements
    private lazy var jumpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypBlack
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleJump), for: .touchUpInside)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        return button
    }()
    
    private lazy var pages: [UIViewController] = {
        return [
            OnboardingPageViewController(pageModel: OnboardingPageModel(
                image: UIImage(resource: .onboarding1), text: "Отслеживайте только то, что хотите"
            )),
            OnboardingPageViewController(pageModel: OnboardingPageModel(
                image: UIImage(resource: .onboarding2), text: "Даже если это не литры воды и йога"
            ))
        ]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        return pageControl
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        if let firstViewController = pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        [pageControl, jumpButton].forEach {
            view.addToView($0)
        }
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: jumpButton.topAnchor, constant: -Constants.pageControlSpacing),
            
            jumpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.buttonSpacing),
            jumpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.buttonSpacing),
            jumpButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            jumpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.buttonBottomInset)
        ])
    }
    
    // MARK: - Actions
    @objc private func handleJump() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        let coreDataStack = CoreDataStack()
        let tabBarController = TabBarController(coreDataStack: coreDataStack)
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}

// MARK: - UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        return previousIndex >= 0 ? pages[previousIndex] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        return nextIndex < pages.count ? pages[nextIndex] : nil
    }
}

// MARK: - UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
