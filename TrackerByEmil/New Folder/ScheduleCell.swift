//
//  ScheduleCell.swift
//  TrackerByEmil
//
//  Created by Emil on 16.06.2025.
//
import UIKit

final class ScheduleCell: UITableViewCell {
    // MARK: - Properties
    static let reusableIdentifier = "ScheduleCell"
    
    // MARK: - UI Element's
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()
    
    lazy var accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .ypGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var AllUIStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, accessoryImageView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        contentView.backgroundColor = .ypBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private functions
    private func setupUI() {
        [AllUIStackView].forEach { contentView.addToView($0) }
        
        NSLayoutConstraint.activate([
            accessoryImageView.widthAnchor.constraint(equalToConstant: 24),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 24),
            
            AllUIStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            AllUIStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            AllUIStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
