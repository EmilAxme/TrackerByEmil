//
//  StatisticViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 05.06.2025.
//

import UIKit

final class StatisticViewController: UIViewController {
    
    private enum Constants {
        static let topAnchor = 24
        
        static let titleLabel = "statistic_title".localized
        static let bestPeriod = "statistic_best_period".localized
        static let perfectDays = "statistic_perfect_days".localized
        static let completedTrackers = "statistic_completed_trackers".localized
        static let averageValue = "statistic_average_value".localized
    }
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleLabel
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var metricsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            makeMetricView(value: "6", description: Constants.bestPeriod),
            makeMetricView(value: "2", description: Constants.perfectDays),
            makeMetricView(value: "5", description: Constants.completedTrackers),
            makeMetricView(value: "4", description: Constants.averageValue)
        ])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupLayout()
    }
    
    // MARK: - Private
    
    private func setupLayout() {
        [titleLabel, metricsStack].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            metricsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            metricsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            metricsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func makeMetricView(value: String, description: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = .label
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.textColor = .label
        
        let stack = UIStackView(arrangedSubviews: [valueLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
}
