//
//  AddToPlaylistViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 17/08/2023.
//

import Foundation
import RealmSwift

class AddToPlaylistViewModel {

	private let realm = RealmService.shared.realmObj()
	private let importPlaylistID = RealmService.shared.getIdImport()
	private let favouritePlaylistID = RealmService.shared.getIdFavourite()
	private let audioConvertPlaylistID = RealmService.shared.getIdAudioConvert()
    private let historyPlaylist = RealmService.shared.getIdHistory()
    
	let musicToAdd: MusicModel

    var playlists: [PlaylistModel] = []
	var onCreatePlaylist: ((_ indexPath: IndexPath) -> Void)?
	var onAddMusicToPlaylist: ((_ message: String, _ indexPath: IndexPath) -> Void)?

	init(music: MusicModel) {
		self.musicToAdd = music
	}

	var numberOfItems: Int {
		return playlists.count
	}

	func getPlaylist(at indexPath: IndexPath) -> PlaylistModel {
		return playlists[indexPath.row]
	}

	func loadAllPlaylists() {
		guard let realm = realm else { return }

		playlists = realm.objects(PlaylistModel.self)
			.where {
				$0.id.notEquals(importPlaylistID, options: .caseInsensitive) &&
				$0.id.notEquals(favouritePlaylistID, options: .caseInsensitive) &&
				$0.id.notEquals(audioConvertPlaylistID, options: .caseInsensitive) &&
                $0.id.notEquals(historyPlaylist, options: .caseInsensitive)
			}
			.sorted(by: \.creationDate, ascending: false)
			.toArray(ofType: PlaylistModel.self)
	}

	func createNewPlaylist(name: String) -> Bool {
		guard let realm = realm else { return false }

		let playlistModel = PlaylistModel()
		playlistModel.name = name
		playlistModel.creationDate = Date().timeIntervalSince1970

		do {
			try realm.write { realm.add(playlistModel) }
			playlists.insert(playlistModel, at: 0)
			onCreatePlaylist?(IndexPath(row: 0, section: 0))
			return true

		} catch {
			return false
		}
	}

	func addMusicToPlaylist(at indexPath: IndexPath) {
		guard let realm = realm else {
			onAddMusicToPlaylist?("Add to playlist failed", indexPath)
			return
		}
		let playlist = playlists[indexPath.row]

		if musicToAdd.sourceType == .online {
			guard playlist.musics.where({ $0.videoID == musicToAdd.videoID }).isEmpty else {
				onAddMusicToPlaylist?("Music already exist in this playlist", indexPath)
				return
			}

		} else if musicToAdd.sourceType == .offline {
			guard playlist.musics.where({ $0.id == musicToAdd.id }).isEmpty else {
				onAddMusicToPlaylist?("Music already exist in this playlist", indexPath)
				return
			}
		}

		do {
			try realm.write { playlist.musics.append(musicToAdd) }
			onAddMusicToPlaylist?("Add to playlist successfully", indexPath)
		} catch {
			onAddMusicToPlaylist?("Add to playlist failed", indexPath)
		}
	}
}
