//
//  PlaylistDetailViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 16/08/2023.
//

import Foundation
import RealmSwift

class PlaylistDetailViewModel {

	private let realm = RealmService.shared.realmObj()
	private var playlist: PlaylistModel
	private var musics: [MusicModel] = []

	var shuffleMode: RandomMode = .none
	var replayMode: ReplayMode = .none
	var onDeleteMusic: (() -> Void)?
	var onRenameMusic: ((_ indexPath: IndexPath) -> Void)?
	var onToggleShuffle: (() -> Void)?
	var onToggleReplay: (() -> Void)?

	init(playlist: PlaylistModel) {
		self.playlist = playlist
		self.musics = playlist.musics.toArray(ofType: MusicModel.self)
	}

	// MARK: - Public
	var numberOfItems: Int {
		return musics.count
	}

	var shuffleBtnImage: String {
		return shuffleMode == .none ? AssetConstant.ic_not_random : AssetConstant.ic_random_selected
	}

	var replayBtnImage: String {
		if replayMode == .none {
			return AssetConstant.ic_not_replay
		} else if replayMode == .all {
			return AssetConstant.ic_replay_all
		} else if replayMode == .ones {
			return AssetConstant.ic_replay_ones
		}
		return ""
	}

	func getMusicModel(at indexPath: IndexPath) -> MusicModel {
		return musics[indexPath.row]
	}

	func getRealPlaylist() -> PlaylistModel {
		return playlist
	}

	func getPlaylistForPlay() -> PlaylistModel {
		let playlist = PlaylistModel()
		playlist.musics.append(objectsIn: musics)
		return playlist
	}

	func deleteMusic(at indexPath: IndexPath) -> Bool {
		guard let realm = realm else { return false }

		let music = musics[indexPath.row]
		guard let indexToRemove = playlist.musics.firstIndex(of: music) else { return false }

		do {
			musics.remove(at: indexPath.row)
			try realm.write { playlist.musics.remove(at: indexToRemove) }
			onDeleteMusic?()
			return true

		} catch {
			return false
		}
	}

	func renameMusic(at indexPath: IndexPath, name: String) -> Bool {
		guard let realm = realm else { return false }
		let music = musics[indexPath.row]

		do {
			try realm.write{ music.name = name }
			onRenameMusic?(indexPath)
			return true

		} catch {
			return false
		}
	}

	func toggleShuffleMode() {
		if shuffleMode == .random {
			musics = playlist.musics.toArray(ofType: MusicModel.self)
			shuffleMode = .none
		} else {
			musics = musics.shuffled()
			shuffleMode = .random
		}
		onToggleShuffle?()
	}

	func toggleReplayMode() {
		if replayMode == .none {
			replayMode = .ones
		} else if replayMode == .ones {
			replayMode = .all
		} else if replayMode == .all {
			replayMode = .none
		}
		onToggleReplay?()
	}

}
