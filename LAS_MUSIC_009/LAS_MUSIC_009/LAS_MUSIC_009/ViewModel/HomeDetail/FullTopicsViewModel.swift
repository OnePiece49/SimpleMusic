//
//  FullTopicsViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 29/08/2023.
//

import Foundation

class FullTopicsViewModel {

	let genres: [YTGenresModel]
//	var onGetGenrePlaylist: ((_ musics: [MusicModel]) -> Void)?

	init(genres: [YTGenresModel]) {
		self.genres = genres
	}

	// MARK: - Public
	var numberOfItems: Int {
		return genres.count
	}

	func getGenreModel(at indexPath: IndexPath) -> YTGenresModel {
		return genres[indexPath.item]
	}

	func getGenrePLaylistDetail(at indexPath: IndexPath, completion: @escaping (_ musics: [MusicModel]) -> Void) {
		let genre = getGenreModel(at: indexPath)
		guard let params = genre.params else { return }

		getPlaylist(params: params, token: nil) { [weak self] tracks, token in
//			self?.onGetGenrePlaylist?(tracks)
			completion(tracks)

			if let token = token {
				self?.getPlaylist(params: nil, token: token) { tracks, token in
//					self?.onGetGenrePlaylist?(tracks)
					completion(tracks)
				}
			}
		}
	}

	// MARK: - Private
	private func getPlaylist(params: String?,
							 token: String?,
							 completion: @escaping (_ tracks: [MusicModel], _ token: String?) -> Void) {
		if let params = params {
			YTMManager.shared.getGenresPLaylistDetail(params: params) { ytModels, token in
				guard let ytModels = ytModels else {
					completion([], nil)
					return
				}
				let musics = ConvertService.shared.convertArrYTSearchToArrMSModel(ytSearchs: ytModels)
				completion(musics, token)
			}

		} else if let token = token {
			YTMManager.shared.getContinuationGenresPLaylistDetail(token: token) { ytModels, token in
				guard let ytModels = ytModels else {
					completion([], nil)
					return
				}
				let musics = ConvertService.shared.convertArrYTSearchToArrMSModel(ytSearchs: ytModels)
				completion(musics, nil)
			}
		}
	}
}
