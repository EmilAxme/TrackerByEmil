//
//  CategoryCell.swift
//  TrackerByEmil
//
//  Created by Emil on 16.06.2025.
//

import UIKit

final class CategoryCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reusableIdentifier = "CategoryCell"
    
    // MARK: - UI Elements
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypGray
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        return view
    }()
    
    lazy var accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .ypGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var labelStackView: UIStackView = {
        let labelStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 2
        return labelStackView
    }()
    
    private lazy var AllUIStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelStackView, accessoryImageView])
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
    
    
    // MARK: - Private methods
    private func setupUI() {
        
        [separatorView, AllUIStackView].forEach { contentView.addToView($0) }
        
        NSLayoutConstraint.activate([
            accessoryImageView.widthAnchor.constraint(equalToConstant: 24),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 24),
            
            AllUIStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            AllUIStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            AllUIStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            AllUIStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
