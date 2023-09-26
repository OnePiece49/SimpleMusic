//
//  HomeTrendingCLCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 29/08/2023.
//

import UIKit
import SDWebImage

protocol HomeTrendingCLCellDelegate: AnyObject {
	func didTapFavorite(_ cell: HomeTrendingCLCell)
}

class HomeTrendingCLCell: BaseCollectionViewCell {

	var viewModel: HomeTrendingCLCellViewModel? {
		didSet { updateUI() }
	}
	weak var delegate: HomeTrendingCLCellDelegate?

	var onTapFavorite: ((_ cell: HomeTrendingCLCell) -> Void)?

	// MARK: - UI components
	private let posterImv: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
		imv.backgroundColor = .purple
		return imv
	}()

	private let titleLbl: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.numberOfLines = 0
		lbl.font = .fontRailwayBold(16)
		lbl.textColor = .white
		lbl.text = "Rich men in"
		return lbl
	}()

	private let artistLbl: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.numberOfLines = 0
		lbl.font = .fontRailwayRegular(12)
		lbl.textColor = .white
		lbl.text = "The Weeknd"
		return lbl
	}()

	private lazy var favoriteBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setImage(UIImage(named: AssetConstant.ic_heart), for: .normal)
		btn.addTarget(self, action: #selector(favoriteBtnTapped), for: .touchUpInside)
		return btn
	}()

	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupConstraints() {
		let stack = UIStackView(arrangedSubviews: [titleLbl, artistLbl])
		stack.axis = .vertical
		stack.spacing = 4
		stack.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(posterImv)
		contentView.addSubview(stack)
		contentView.addSubview(favoriteBtn)

		posterImv.pinToView(contentView)

		stack.anchor(leading: contentView.leadingAnchor, paddingLeading: 20,
					 trailing: favoriteBtn.leadingAnchor, paddingTrailing: 12,
					 bottom: contentView.bottomAnchor, paddingBottom: -12)

		favoriteBtn.anchor(trailing: contentView.trailingAnchor, paddingTrailing: -8,
						   bottom: stack.bottomAnchor)
		favoriteBtn.setDimensions(width: 36, height: 36)
	}

	@objc private func favoriteBtnTapped() {
//		delegate?.didTapFavorite(self)
		onTapFavorite?(self)
	}

	private func updateUI() {
		posterImv.sd_setImage(with: viewModel?.thumbnailUrl, placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default))
		titleLbl.text = viewModel?.musicTitle
		artistLbl.text = viewModel?.artist
		favoriteBtn.setImage(viewModel?.favouriteImage, for: .normal)
	}
}
