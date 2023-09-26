//
//  FavouriteDetailTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 18/08/2023.
//

import UIKit

protocol FavouriteDetailTBCellDelegate: AnyObject {
	func didTapUnfavourite(_ cell: FavouriteDetailTBCell)
}

class FavouriteDetailTBCell: BaseMyFileTBCell {

	weak var delegate: FavouriteDetailTBCellDelegate?

	var music: MusicModel? {
		didSet {
			let thumbnailURL = URL(string: music?.thumbnailURL ?? "")
			thumbnailImv.sd_setImage(with: thumbnailURL,
									 placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default),
									 context: .none)
			nameLbl.text = music?.name
            if music?.sourceType == .offline {
                durationOrCountLbl.text = music?.durationDouble.toString()
            } else {
                durationOrCountLbl.text = music?.durationString
            }
			
		}
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		moreButton.setImage(UIImage(named: AssetConstant.ic_heart_fill)?.withRenderingMode(.alwaysOriginal), for: .normal)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		moreButton.setImage(UIImage(named: AssetConstant.ic_heart_fill)?.withRenderingMode(.alwaysOriginal), for: .normal)
	}

	override func moreButtonTapped() {
		delegate?.didTapUnfavourite(self)
	}
}
