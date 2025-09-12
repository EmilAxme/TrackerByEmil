//
//  OnboardingViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 10.09.2025.
//

import UIKit

class OnboardingViewController: UIPageViewController {
    
    // MARK: - Layout Constants
    private enum Constants {
        static let buttonCornerRadius: CGFloat = 12
        static let buttonWidthMultiplier: CGFloat = 0.5
        static let buttonHeight: CGFloat = 60
        static let buttonBottomInset: CGFloat = 50
        static let pageControlSpacing: CGFloat = 24
    }
    
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
        let first = UIViewController()
        let imageView1 = UIImageView(image: UIImage(named: "Onboarding1"))
        first.view.addToView(imageView1)
        backgroundImageConstrains(image: imageView1, view: first.view)
        
        let second = UIViewController()
        let imageView2 = UIImageView(image: UIImage(named: "Onboarding2"))
        second.view.addToView(imageView2)
        backgroundImageConstrains(image: imageView2, view: second.view)
        
        return [first, second]
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
            
            jumpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            jumpButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.buttonWidthMultiplier),
            jumpButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            jumpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.buttonBottomInset)
        ])
    }
    
    private func backgroundImageConstrains(image: UIImageView, view: UIView) {
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: view.topAnchor),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
extension OnboardingViewController: UIPageViewControllerDataSource {
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
extension OnboardingViewController: UIPageViewControllerDelegate {
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
