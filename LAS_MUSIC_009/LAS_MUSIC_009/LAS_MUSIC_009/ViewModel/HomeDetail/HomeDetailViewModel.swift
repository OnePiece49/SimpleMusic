//
//  HomeDetailViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 29/08/2023.
//

import Foundation

class HomeDetailViewModel {

	private var musics: [MusicModel]
	private var shuffledMusics: [MusicModel]

	var shuffleMode: RandomMode = .none
	var replayMode: ReplayMode = .none
	var onToggleShuffle: (() -> Void)?
	var onToggleReplay: (() -> Void)?

	init(musics: [MusicModel]) {
		self.musics = musics
		self.shuffledMusics = musics
	}

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
		return shuffleMode == .none ? musics[indexPath.row] : shuffledMusics[indexPath.row]
	}

	func getPlaylist() -> PlaylistModel {
		let playlist = PlaylistModel()
		let musics = shuffleMode == .none ? musics : shuffledMusics
		playlist.musics.append(objectsIn: musics)
		return playlist
	}

	func toggleShuffleMode() {
		if shuffleMode == .random {
			shuffledMusics = musics
			shuffleMode = .none
		} else {
			shuffledMusics = shuffledMusics.shuffled()
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
