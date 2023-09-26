//
//  OneDriveTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 15/08/2023.
//

import UIKit

class OneDriveTBCell: BaseImportTBCell {

	var model: OneDriveModel? {
		didSet {
			guard let model = model else { return }
			nameLbl.text = model.name

			if let audio = model.audio {
				fileSizeLbl.text = (audio.duration/1000).toString()

			} else if let video = model.video {
				fileSizeLbl.text = (video.duration/1000).toString()

			} else {
				fileSizeLbl.text = getFileSize(byte: Int64(model.size))
			}
		}
	}

}
