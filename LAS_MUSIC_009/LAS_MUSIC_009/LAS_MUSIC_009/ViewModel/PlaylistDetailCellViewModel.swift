//
//  PlaylistDetailCellViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 17/08/2023.
//

import Foundation

struct PlaylistDetailCellViewModel {

	var music: MusicModel
	var indexPath: IndexPath

	init(music: MusicModel, indexPath: IndexPath) {
		self.music = music
		self.indexPath = indexPath
	}

	var numericString: String {
		if indexPath.row + 1 < 10 {
			return "0\(indexPath.row + 1)"
		}
		return "\(indexPath.row + 1)"
	}

	var thumbnailURL: URL? {
		if let thumbStr = music.thumbnailURL {
			return URL(string: thumbStr)
		}
		return nil
	}

	var musicName: String {
		return music.name
	}

	var artist: String? {
		return music.artist
	}

}
