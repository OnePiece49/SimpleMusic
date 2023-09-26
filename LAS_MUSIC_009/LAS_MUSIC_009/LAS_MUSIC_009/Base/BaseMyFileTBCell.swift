//
//  BaseMyFileTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 16/08/2023.
//

import UIKit

class BaseMyFileTBCell: BaseTableViewCell {

	static let cellHeight: CGFloat = 80

	// MARK: - UI components
	let thumbnailImv: UIImageView = {
		let iv = UIImageView()
		iv.translatesAutoresizingMaskIntoConstraints = false
		iv.contentMode = .scaleAspectFill
		iv.layer.cornerRadius = 3
		iv.clipsToBounds = true
		return iv
	}()

	let nameLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 2
		label.textColor = .white
		label.font = .fontRailwaySemiBold(16)
		return label
	}()

	let durationOrCountLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(rgb: 0x979797)
		label.font = .fontRailwayRegular(12)
		return label
	}()

	lazy var moreButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(named: AssetConstant.ic_more)?.withRenderingMode(.alwaysOriginal), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
		return button
	}()

	//MARK: - View Lifecycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	//MARK: - Helpers
	func configureUI() {
		let stack = UIStackView(arrangedSubviews: [nameLbl, durationOrCountLbl])
		stack.spacing = 4
		stack.axis = .vertical
		stack.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(thumbnailImv)
		contentView.addSubview(stack)
		contentView.addSubview(moreButton)

		thumbnailImv.anchor(leading: contentView.leadingAnchor, paddingLeading: 20,
							top: contentView.topAnchor, paddingTop: 12,
							bottom: contentView.bottomAnchor, paddingBottom: -12)
		thumbnailImv.setDimension(multiplier: 1)

		stack.anchor(leading: thumbnailImv.trailingAnchor, paddingLeading: 20,
					 trailing: moreButton.leadingAnchor, paddingTrailing: -20)
		stack.centerY(centerY: thumbnailImv.centerYAnchor)

		moreButton.anchor(trailing: contentView.trailingAnchor, paddingTrailing: -20,
						  width: 36, height: 36)
		moreButton.centerY(centerY: thumbnailImv.centerYAnchor)
	}

	//MARK: - Selectors
	@objc func moreButtonTapped() {
		
	}

}
