//
//  TabBarController.swift
//  TrackerByEmil
//
//  Created by Emil on 05.06.2025.
//

import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
    }
    
    // MARK: - Private Methods
    
    private func setupTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let mainScreenVC = storyboard.instantiateViewController(withIdentifier: "MainScreenViewController") as? TrackerViewController else {
            assertionFailure("Не удалось инициализировать MainScreenViewController")
            return
        }
        
        let statisticVC = StatisticViewController()
        
        mainScreenVC.tabBarItem = UITabBarItem(title: "Главный", image: UIImage(named: "mainTabItem"), selectedImage: nil)
        statisticVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statTabItem"), selectedImage: nil)
        
        self.viewControllers = [mainScreenVC, statisticVC]
        
        addSeparatorLine()
    }
    
    private func addSeparatorLine() {
        let separatorLine = UIView()
        separatorLine.backgroundColor = .lightGray
        
        view.addToView(separatorLine)
        
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: self.tabBar.topAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
