//
//  DaysSelectCell.swift
//  TrackerByEmil
//
//  Created by Emil on 17.06.2025.
//

import UIKit

final class DaysSelectCell: UITableViewCell {

    // MARK: - Layout Constants

    private enum Layout {
        static let horizontalInset: CGFloat = 16
    }

    // MARK: - Properties

    static let reusableIdentifier = "DaysSelectCell"
    private var switchCallback: ((Bool) -> Void)?

    // MARK: - UI Elements

    lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    lazy var toggleSwitch: UISwitch = {
        let switchButton = UISwitch()
        switchButton.onTintColor = .systemBlue
        switchButton.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        return switchButton
    }()

    private lazy var allUIStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dayLabel, toggleSwitch])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assertionFailure("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with day: WeekDay, isOn: Bool, switchChanged: @escaping (Bool) -> Void) {
        switchCallback = switchChanged
        dayLabel.text = day.fullName
        toggleSwitch.isOn = isOn
    }

    // MARK: - Private Methods

    private func setupUI() {
        contentView.addToView(allUIStackView)

        NSLayoutConstraint.activate([
            allUIStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalInset),
            allUIStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalInset),
            allUIStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    private func configureAppearance() {
        contentView.backgroundColor = .ypBackground
        selectionStyle = .none
    }

    // MARK: - Actions

    @objc private func switchValueChanged(_ sender: UISwitch) {
        switchCallback?(sender.isOn)
    }
}
