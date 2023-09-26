//
//  HomeTopicVM.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 31/08/2023.
//

import Foundation

class HomeTopicVM {

	var genres: [YTGenresModel] = []
	var onGetGenres: (() -> Void)?

	func getAllGenres() {
		YTMManager.shared.getAllGenres { [weak self] genres in
			guard let self = self else { return }
			self.genres = genres
			self.onGetGenres?()
		}
	}

	func getGenrePLaylistDetail(genre: YTGenresModel, completion: @escaping (_ tracks: [MusicModel]) -> Void) {
		guard let params = genre.params else { return }

		YTMManager.shared.getGenresPLaylistDetail(params: params) { ytModels, token in
			guard let ytModels = ytModels else { return }
			let musics = ConvertService.shared.convertArrYTSearchToArrMSModel(ytSearchs: ytModels)
			completion(musics)
		}
	}
}
