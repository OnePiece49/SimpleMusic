//
//  DownloadedTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 15/08/2023.
//

import UIKit
import SDWebImage

protocol ImportedDetailTBCellDelegate: AnyObject {
	func didSelectMore(_ cell: ImportedDetailTBCell)
}

class ImportedDetailTBCell: BaseMyFileTBCell {

	weak var delegate: ImportedDetailTBCellDelegate?

	var music: MusicModel? {
		didSet {
			let thumbnailURL = URL(string: music?.thumbnailURL ?? "")
			thumbnailImv.sd_setImage(with: thumbnailURL,
									 placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default),
									 context: .none)
			nameLbl.text = music?.name
			durationOrCountLbl.text = music?.durationDouble.toString()
		}
	}

	override func moreButtonTapped() {
		delegate?.didSelectMore(self)
	}
}
