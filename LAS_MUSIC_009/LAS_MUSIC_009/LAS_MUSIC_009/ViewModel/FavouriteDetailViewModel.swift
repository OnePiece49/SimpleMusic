//
//  FavouriteDetailViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 16/08/2023.
//

import Foundation
import RealmSwift

class FavouriteDetailViewModel {

	private let realm = RealmService.shared.realmObj()
    let favouritePlaylist = RealmService.shared.favouritePlaylist()

	var musics: [MusicModel] = []
	var onUnFavouriteMusic: ((_ indexPath: IndexPath) -> Void)?

	var numberOfItems: Int {
		return musics.count
	}

	func getMusicModel(at indexPath: IndexPath) -> MusicModel {
		return musics[indexPath.row]
	}

	func loadAllMusics() {
		guard let favouritePlaylist = favouritePlaylist else { return }
		musics = favouritePlaylist.musics.toArray(ofType: MusicModel.self)
	}

	func unFavouriteMusic(at indexPath: IndexPath) -> Bool {
		let music = musics[indexPath.row]
		let success = RealmService.shared.removeFromFavourite(music: music)
		postNotification(music: music)

		if success {
			musics.remove(at: indexPath.row)
			onUnFavouriteMusic?(indexPath)
		}
		return success
	}

	private func postNotification(music: MusicModel) {
		NotificationCenter.default.post(name: .updateLikeButtonToPlayerController, object: nil, userInfo: ["music": music])
		NotificationCenter.default.post(name: .updateLikeButtonToOtherControllers, object: nil, userInfo: ["music": music])
	}
}
