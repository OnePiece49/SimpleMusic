//
//  HomeTrendingCLCellViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 30/08/2023.
//

import UIKit

struct HomeTrendingCLCellViewModel {

	var music: MusicModel

	init(music: MusicModel) {
		self.music = music
	}

	var favouriteImage: UIImage? {
		if music.isFavorited {
			return UIImage(named: AssetConstant.ic_heart_fill)?.withRenderingMode(.alwaysOriginal)
		}
		return UIImage(named: AssetConstant.ic_heart)?.withRenderingMode(.alwaysOriginal)
	}

	var musicTitle: String {
		return music.name
	}

	var artist: String? {
		return music.artist
	}

	var thumbnailUrl: URL? {
		if let urlString = music.thumbnailURL {
			return URL(string: urlString)
		}
		return nil
	}

}
