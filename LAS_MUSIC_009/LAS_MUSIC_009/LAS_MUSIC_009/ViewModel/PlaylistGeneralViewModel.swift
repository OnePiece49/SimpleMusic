//
//  PlaylistGeneralCellViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 16/08/2023.
//

import Foundation
import RealmSwift

class PlaylistGeneralViewModel {

	private let realm = RealmService.shared.realmObj()
	private let importPlaylistID = RealmService.shared.getIdImport()
	private let favouritePlaylistID = RealmService.shared.getIdFavourite()
	private let audioConvertPlaylistID = RealmService.shared.getIdAudioConvert()
    private let historyPlaylist = RealmService.shared.getIdHistory()
    

	var playlists: [PlaylistModel] = []
	var onCreatePlaylist: ((_ indexPath: IndexPath) -> Void)?
	var onRenamePlaylist: ((_ indexPath: IndexPath) -> Void)?
	var onDeletePlaylist: ((_ indexPath: IndexPath) -> Void)?

	var numberOfItems: Int {
		return playlists.count
	}

	func getPlaylist(at indexPath: IndexPath) -> PlaylistModel {
		return playlists[indexPath.row]
	}

	func getIndexForPlaylist(_ playlist: PlaylistModel) -> Int? {
		return playlists.firstIndex(of: playlist)
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

	func renamePlaylist(at indexPath: IndexPath, name: String) -> Bool {
		guard let realm = realm else { return false }
		let playlist = playlists[indexPath.row]

		do {
			try realm.write { playlist.name = name }
			onRenamePlaylist?(indexPath)
			return true
		} catch {
			return false
		}
	}

	func deletePlaylist(at indexPath: IndexPath) -> Bool {
		guard let realm = realm else { return false }
		let playlist = playlists[indexPath.row]

		do {
			playlists.remove(at: indexPath.row)
			try realm.write { realm.delete(playlist) }
			onDeletePlaylist?(indexPath)
			return true
		} catch {
			return false
		}
	}

}
