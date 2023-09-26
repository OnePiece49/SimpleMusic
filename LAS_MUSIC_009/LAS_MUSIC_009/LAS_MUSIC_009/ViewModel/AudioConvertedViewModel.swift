//
//  AudioConvertedViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 17/08/2023.
//

import UIKit

class AudioConvertedViewModel {

    private let realm = RealmService.shared.realmObj()
    private let audioPlaylist = RealmService.shared.audioConvertPlaylist()

    var musics: [MusicModel] = []
    var onDeleteMusic: ((_ index: Int) -> Void)?

    var numberOfItems: Int {
        return musics.count
    }

    func getMusicModel(at indexPath: IndexPath) -> MusicModel {
        return musics[indexPath.row]
    }
    
    var playlist: PlaylistModel? {
        return audioPlaylist
    }

    func loadAllMusics() {
        guard let audioPlaylist = audioPlaylist else { return }
        musics = audioPlaylist.musics.toArray(ofType: MusicModel.self)
    }

    func deleteMusic(_ music: MusicModel) -> Bool {
        guard let realm = realm else { return false }
        guard let deleteIndex = musics.firstIndex(where: { $0.id == music.id }) else { return false }

        do {
            musics.remove(at: deleteIndex)

            if let url = music.absolutePath {
                try FileManager.default.removeItem(at: url)
            }
            try realm.write { realm.delete(music) }

            onDeleteMusic?(deleteIndex)
            return true

        } catch {
            return false
        }
    }
}
