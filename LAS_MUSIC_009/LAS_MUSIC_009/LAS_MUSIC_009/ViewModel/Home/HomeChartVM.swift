//
//  HomeChartVM.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 31/08/2023.
//

import Foundation

class HomeChartVM {

	var musics: [MusicModel] = []
	var onGetMusicChart: (() -> Void)?

	func getPlaylistModel() -> PlaylistModel {
		let playlist = PlaylistModel()
		playlist.musics.append(objectsIn: musics)
		return playlist
	}

	func getMusicChart() {
		YTMManager.shared.getMusicChart { [weak self] result in
			let ytMusics = result.musicChart
			self?.musics = ConvertService.shared.convertArrYTSearchToArrMSModel(ytSearchs: ytMusics)
			self?.onGetMusicChart?()
		}
	}

}
