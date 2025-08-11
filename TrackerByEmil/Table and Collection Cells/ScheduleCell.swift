//
//  ScheduleCell.swift
//  TrackerByEmil
//
//  Created by Emil on 16.06.2025.
//
import UIKit

final class ScheduleCell: UITableViewCell {
    
    // MARK: - Layout Constants
    
    private enum Layout {
        static let sideInset: CGFloat = 16
        static let imageSize: CGFloat = 24
    }
    
    // MARK: - Properties
    
    static let reusableIdentifier = "ScheduleCell"
    

    
    // MARK: - UI Elements
    
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
    
    private lazy var allUIStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, accessoryImageView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        contentView.backgroundColor = .ypBackground
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assertionFailure("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        contentView.addToView(allUIStackView)
        
        NSLayoutConstraint.activate([
            accessoryImageView.widthAnchor.constraint(equalToConstant: Layout.imageSize),
            accessoryImageView.heightAnchor.constraint(equalToConstant: Layout.imageSize),
            
            allUIStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.sideInset),
            allUIStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.sideInset),
            allUIStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
