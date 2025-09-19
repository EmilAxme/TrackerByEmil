//
//  StatisticViewController.swift
//  TrackerByEmil
//
//  Created by Emil on 05.06.2025.
//

import UIKit

final class StatisticViewController: UIViewController {
    
    private enum Constants {
        static let titleLabel = "statistic_title".localized
        static let completedTrackers = "statistic_completed_trackers".localized
        static let stubLabel = "statistic_stub_label".localized
    }
    
    // MARK: - Properties
    
    private let statsStore = TrackerStatsStore()
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleLabel
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var metricsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Pechalik")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.stubLabel
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMetrics()
    }
    
    // MARK: - Private
    
    private func updateMetrics() {
        let stat = statsStore.getCompletedCount()
        
        metricsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if stat == 0 {
            metricsStack.isHidden = true
            stubImage.isHidden = false
            stubLabel.isHidden = false
        } else {
            metricsStack.isHidden = false
            stubImage.isHidden = true
            stubLabel.isHidden = true
            
            let view = makeMetricView(value: String(stat), description: Constants.completedTrackers)
            metricsStack.addArrangedSubview(view)
        }
    }
    
    private func setupLayout() {
        [titleLabel, metricsStack, stubImage, stubLabel].forEach {
            view.addToView($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            metricsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            metricsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            metricsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            stubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stubImage.widthAnchor.constraint(equalToConstant: 80),
            stubImage.heightAnchor.constraint(equalToConstant: 80),
            
            stubLabel.topAnchor.constraint(equalTo: stubImage.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            stubLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
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
