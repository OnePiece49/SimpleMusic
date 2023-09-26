//
//  MusicChartDetailTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 29/08/2023.
//

import UIKit

class MusicChartDetailTBCell: BaseTableViewCell {

	static let cellHeight: CGFloat = 70

	var viewModel: PlaylistDetailCellViewModel? {
		didSet { updateUI() }
	}
	var onSelectMore: ((_ cell: MusicChartDetailTBCell, _ music: MusicModel) -> Void)?

	// MARK: - UI components
	private let numericLbl: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.numberOfLines = 1
		lbl.font = .fontRailwaySemiBold(14)
		lbl.textColor = .white
		lbl.text = "01"
		lbl.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
		return lbl
	}()

	private let thumbnailImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
		imv.layer.cornerRadius = 3
		imv.clipsToBounds = true
		imv.backgroundColor = .systemPink
		return imv
	}()

	private lazy var musicNameLbl: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.numberOfLines = 2
		lbl.textColor = UIColor(rgb: 0xEEEEEE)
		lbl.font = .fontRailwaySemiBold(16)
		lbl.text = "I love you"
		return lbl
	}()

	private lazy var artistLbl: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.numberOfLines = 1
		lbl.textColor = UIColor(rgb: 0x71737B)
		lbl.font = .fontRailwayRegular(12)
		lbl.text = "Hehee"
		return lbl
	}()

	private lazy var moreBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.setImage(UIImage(named: AssetConstant.ic_more)?.withRenderingMode(.alwaysOriginal), for: .normal)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
		return btn
	}()

	// MARK: - Init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupConstraints()
	}

	private func setupConstraints() {
		let stack = UIStackView(arrangedSubviews: [musicNameLbl, artistLbl])
		stack.spacing = 4
		stack.axis = .vertical

		contentView.addSubview(numericLbl)
		contentView.addSubview(thumbnailImv)
		contentView.addSubview(stack)
		contentView.addSubview(moreBtn)

		// numeric label
		numericLbl.anchor(leading: contentView.leadingAnchor, paddingLeading: 12)
		numericLbl.centerY(centerY: contentView.centerYAnchor)

		// thumbnail image view
		thumbnailImv.anchor(leading: numericLbl.trailingAnchor, paddingLeading: 12,
							top: contentView.topAnchor, paddingTop: 12,
							bottom: contentView.bottomAnchor, paddingBottom: -12)

		thumbnailImv.setDimension(multiplier: 1)

		// label stack view
		stack.anchor(leading: thumbnailImv.trailingAnchor, paddingLeading: 16,
					 trailing: moreBtn.leadingAnchor, paddingTrailing: -8)

		stack.centerY(centerY: thumbnailImv.centerYAnchor)

		// more button
		moreBtn.anchor(trailing: contentView.trailingAnchor, paddingTrailing: -8,
					   width: 36, height: 36)

		moreBtn.centerY(centerY: thumbnailImv.centerYAnchor)
	}

	@objc private func moreButtonTapped() {
		guard let viewModel = viewModel else { return }
		onSelectMore?(self, viewModel.music)
	}

	private func updateUI() {
		numericLbl.text = viewModel?.numericString
		thumbnailImv.sd_setImage(with: viewModel?.thumbnailURL, placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default))
		musicNameLbl.text = viewModel?.musicName
		artistLbl.text = viewModel?.artist
	}

}
