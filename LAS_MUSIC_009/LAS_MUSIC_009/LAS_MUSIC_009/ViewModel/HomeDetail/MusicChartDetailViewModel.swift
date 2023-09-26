//
//  MusicChartDetailViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 29/08/2023.
//

import Foundation

class MusicChartDetailViewModel {

	var musics: [MusicModel]

	init(musics: [MusicModel]) {
		self.musics = musics
	}

	var numberOfItems: Int {
		return musics.count
	}

	func getMusicModel(at indexPath: IndexPath) -> MusicModel {
		return musics[indexPath.row]
	}

}
