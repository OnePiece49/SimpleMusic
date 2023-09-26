//
//  SettingsItemTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 14/08/2023.
//

import UIKit

class SettingsItemTBCell: UITableViewCell {

	static let cellHeight: CGFloat = 66

	var option: SettingsOption? {
		didSet {
			guard let option = option else { return }
			iconImv.image = UIImage(named: option.iconName)
			titleLbl.text = option.title
			switchControl.isHidden = !(option == .notification)
		}
	}

	// MARK: - UI components
	private let iconImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
		return imv
	}()

	private let titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontRailwayRegular(14)
		label.textColor = UIColor(rgb: 0xEEEEEE)
		return label
	}()

	private lazy var switchControl: UISwitch = {
		let control = UISwitch()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.isHidden = true
		control.isOn = false
		control.isEnabled = true
		control.onTintColor = .primaryYellow
		control.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
		return control
	}()

	private let separatorView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white.withAlphaComponent(0.6)
		return view
	}()

	// MARK: - Init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .clear
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupConstraints()
	}

	private func setupConstraints() {
		contentView.addSubview(iconImv)
		contentView.addSubview(titleLbl)
		contentView.addSubview(switchControl)
		contentView.addSubview(separatorView)

		// icon image view
		iconImv.anchor(leading: contentView.leadingAnchor, paddingLeading: 24,
					   width: 22,height: 22)
		iconImv.centerY(centerY: contentView.centerYAnchor)

		// title label
		titleLbl.anchor(leading: iconImv.trailingAnchor, paddingLeading: 20)
		titleLbl.centerY(centerY: iconImv.centerYAnchor)

		// switch control
		switchControl.anchor(leading: titleLbl.trailingAnchor, paddingLeading: 12,
							 trailing: contentView.trailingAnchor, paddingTrailing: -12)
		switchControl.centerY(centerY: iconImv.centerYAnchor)

		// separator view
		separatorView.anchor(leading: contentView.leadingAnchor, paddingLeading: 28,
							 trailing: contentView.trailingAnchor, paddingTrailing: -20,
							 bottom: contentView.bottomAnchor, height: 0.5)
	}

	func toggleSwitch(isOn: Bool) {
		switchControl.setOn(isOn, animated: true)
	}
}
