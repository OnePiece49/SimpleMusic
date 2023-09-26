//
//  HomeTrendingVM.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 31/08/2023.
//

import Foundation

class HomeTrendingVM {

	var musics: [MusicModel] = []
	var onGetTrendingMusics: (() -> Void)?
	var onToggleFavorite: (() -> Void)?

	func getPlaylistModel() -> PlaylistModel {
		let playlist = PlaylistModel()
		playlist.musics.append(objectsIn: musics)
		return playlist
	}

	func getTrendingMusics() {
		YTMManager.shared.getMusicChart { [weak self] result in
			let ytMusics = result.trending
			self?.musics = ConvertService.shared.convertAndCheckMusicModels(ytModels: ytMusics)
			self?.onGetTrendingMusics?()
		}
	}

}
