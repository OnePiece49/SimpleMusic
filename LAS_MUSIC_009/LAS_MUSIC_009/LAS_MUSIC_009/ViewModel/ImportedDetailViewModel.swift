//
//  DownloadedViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 15/08/2023.
//

import Foundation
import RealmSwift

class ImportedDetailViewModel {

	private let realm = RealmService.shared.realmObj()
	private let importedPlaylist = RealmService.shared.importPlaylist()

	var musics: [MusicModel] = []
	var onDeleteMusic: ((_ indexPath: IndexPath) -> Void)?

	var numberOfItems: Int {
		return musics.count
	}

	func getMusicModel(at indexPath: IndexPath) -> MusicModel {
		return musics[indexPath.row]
	}
    
    var playlist: PlaylistModel? {
        return importedPlaylist
    }

	func loadAllMusics() {
		guard let importedPlaylist = importedPlaylist else { return }
		musics = importedPlaylist.musics.toArray(ofType: MusicModel.self)
	}

	func deleteMusic(at indexPath: IndexPath) -> Bool {
		guard let realm = realm else { return false }
		let music = getMusicModel(at: indexPath)

		do {
			musics.remove(at: indexPath.row)

			if let fileUrl = music.absolutePath {
				try FileManager.default.removeItem(at: fileUrl)
			}

			if let urlString = music.thumbnailURL, let thumbnailUrl = URL(string: urlString), urlString.hasPrefix("file") {
				try FileManager.default.removeItem(at: thumbnailUrl)
			}

			try realm.write { realm.delete(music) }
			onDeleteMusic?(indexPath)
			return true

		} catch {
			return false
		}
	}

}
