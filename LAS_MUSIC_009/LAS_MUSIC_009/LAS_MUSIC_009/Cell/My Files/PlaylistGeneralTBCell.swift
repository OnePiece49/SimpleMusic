//
//  PlaylistGeneralTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 16/08/2023.
//

import UIKit

protocol PlaylistGeneralTBCellDelegate: AnyObject {
	func didSelectMore(_ cell: PlaylistGeneralTBCell)
}

class PlaylistGeneralTBCell: BaseMyFileTBCell {

	var playlist: PlaylistModel? {
		didSet { updateUI() }
	}
	weak var delegate: PlaylistGeneralTBCellDelegate?

	private func updateUI() {
		guard let playlist = playlist else {return}
		self.nameLbl.text = playlist.name
		self.durationOrCountLbl.text = (playlist.musics.count <= 1) ? "\(playlist.musics.count) music" : "\(playlist.musics.count) musics"
		self.thumbnailImv.sd_setImage(with: URL(string: playlist.musics.first?.thumbnailURL ?? ""), placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default), context: .none)
	}

	override func moreButtonTapped() {
		delegate?.didSelectMore(self)
	}
}
