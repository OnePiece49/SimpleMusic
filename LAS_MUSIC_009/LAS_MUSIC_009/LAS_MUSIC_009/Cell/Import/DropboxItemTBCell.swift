//
//  DropboxItemTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 15/08/2023.
//

import UIKit
import SwiftyDropbox

class DropboxItemTBCell: BaseImportTBCell {

	var file: Files.FileMetadata? {
		didSet {
			guard let file = file else { return }
			nameLbl.text = file.name
			fileSizeLbl.text = getFileSize(byte: Int64(file.size))
		}
	}

}
