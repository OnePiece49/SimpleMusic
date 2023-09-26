//
//  RealmService.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 14/08/2023.
//

import UIKit


import UIKit
import RealmSwift


class RealmService: NSObject {

    static let shared = RealmService()

    // MARK: - Private
    private let idImportPlaylist = "43AD7742-8B66-4F20-817F-805CFA60954C"
    private let idFavouritePlaylist = "8145561B-D78A-4C67-934C-0A40730AB000"
	private let idAudioConvertPlaylist = "2EF357E1-8AE6-4EC5-99DA-5B06DCD4D1E7"
    private let idHistory = "55A35745-8B76-4F20-817F-409CAAA09559F"
    
    private let config = Realm.Configuration(schemaVersion: 1)

    override init() { }

    // MARK: - Public
    func configuration() {
        do {
            let realm = try Realm(configuration: config)
            
            if realm.objects(PlaylistModel.self).first(where: { $0.id == idImportPlaylist }) == nil {
                let obj = PlaylistModel()
                obj.id = idImportPlaylist
                obj.name = "Imports"
				obj.creationDate = Date().timeIntervalSince1970
                try? realm.write { realm.add(obj) }
            }
            
            if realm.objects(PlaylistModel.self).first(where: { $0.id == idFavouritePlaylist }) == nil {
                let obj = PlaylistModel()
                obj.id = idFavouritePlaylist
                obj.name = "Favourite"
                obj.creationDate = Date().timeIntervalSince1970
                try? realm.write { realm.add(obj) }
            }

			if realm.objects(PlaylistModel.self).first(where: { $0.id == idAudioConvertPlaylist }) == nil {
				let obj = PlaylistModel()
				obj.id = idAudioConvertPlaylist
				obj.name = "AudioConvert"
				obj.creationDate = Date().timeIntervalSince1970
				try? realm.write {realm.add(obj) }
			}
            
            if realm.objects(PlaylistModel.self).first(where: { $0.id == idHistory }) == nil {
                let obj = PlaylistModel()
                obj.id = idHistory
                obj.name = "History"
                obj.creationDate = Date().timeIntervalSince1970
                try? realm.write {realm.add(obj) }
            }

        } catch (let error) {
            print("Realm error: \(error.localizedDescription)")
        }
    }

    func realmObj() -> Realm? {
        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch {
            print("DEBUG: \(#function) - error: \(error)")
            return nil
        }
    }
    
    func saveImport() {
        
    }
    
    func importPlaylist() -> PlaylistModel? {
        guard let realm = self.realmObj() else { return nil }
        return realm.objects(PlaylistModel.self).first(where: { $0.id == idImportPlaylist })
    }
    
    func historyPlaylist() -> PlaylistModel? {
        guard let realm = self.realmObj() else { return nil }
        return realm.objects(PlaylistModel.self).first(where: { $0.id == idHistory })
    }

    func favouritePlaylist() -> PlaylistModel? {
        guard let realm = self.realmObj() else { return nil }
        return realm.objects(PlaylistModel.self).first(where: { $0.id == idFavouritePlaylist })
    }

	func audioConvertPlaylist() -> PlaylistModel? {
		guard let realm = self.realmObj() else { return nil }
		return realm.objects(PlaylistModel.self).first(where: { $0.id == idAudioConvertPlaylist })
	}
    
    func getIdHistory() -> String {
        return idHistory
    }

    func getIdImport() -> String {
        return idImportPlaylist
    }

    func getIdFavourite() -> String {
        return idFavouritePlaylist
    }

	func getIdAudioConvert() -> String {
		return idAudioConvertPlaylist
	}
    
    func dontAllowDeleteFolder(_ id: String) -> Bool {
        return id == idImportPlaylist || id == idFavouritePlaylist || id == idAudioConvertPlaylist
    }
}

// MARK: - Public methods
extension RealmService {
	func saveObject(_ object: Object) -> Bool {
		guard let realm = realmObj() else { return false }
		do {
			try realm.write { realm.add(object) }
			return true
		} catch {
			print("DEBUG:  \(#function) - error: \(error)")
			return false
		}
	}

	func getAllMusics() -> [MusicModel]? {
		guard let realm = realmObj() else { return nil }
		let musics = realm.objects(MusicModel.self)
		return musics.toArray(ofType: MusicModel.self)
	}

	func saveToFavourite(music: MusicModel, shoudSave saveMSToRealm: Bool) -> Bool {
		if self.favouritePlaylist()?.musics.first(where: { ms in
			switch music.sourceType {
				case .offline:
					return ms.absolutePath == music.absolutePath
				case .online:
					return ms.videoID == music.videoID
				default:
					return false
			}
		}) != nil {
			return false
		}

		if saveMSToRealm {
			if (self.getAllMusics()?.firstIndex(where: { ms in
				return ms.videoID == music.videoID
			})) == nil {
				let success = saveObject(music)
				if !success {return false}
			}
		}

		do {
			try realmObj()?.write({
				music.isFavorited = true
				self.favouritePlaylist()?.musics.append(music)
			})
			return true
		} catch {
			return false
		}
	}

	func saveToFavourite(music: MusicModel) -> Bool {
		if self.favouritePlaylist()?.musics.first(where: { ms in
			switch music.sourceType {
				case .offline:
					return ms.absolutePath == music.absolutePath
				case .online:
					return ms.videoID == music.videoID
				default:
					return false
			}
		}) != nil {
			return false
		}

		if !isExistedMusic(music: music) {
			let success = saveObject(music)
			if !success { return false }
		}

		do {
			try realmObj()?.write({
				music.isFavorited = true
				self.favouritePlaylist()?.musics.append(music)
			})
			return true
		} catch {
			return false
		}
	}

	func removeFromFavourite(music: MusicModel) -> Bool {
		guard let index = self.favouritePlaylist()?.musics.firstIndex(where: { ms in
			switch music.sourceType {
				case .offline:
					return ms.id == music.id
				case .online:
					return ms.videoID == music.videoID
				default:
					return false
			}
		}) else {
			return false
		}

		do {
			try realmObj()?.write({
				music.isFavorited = false
				self.favouritePlaylist()?.musics.remove(at: index)
			})
			return true
		} catch {
			return false
		}
	}

	func isExistedMusic(music: MusicModel) -> Bool {
		if ((self.realmObj()?.objects(MusicModel.self).first(where: { ms in
			if music.sourceType == .online {
				return music.videoID == music.videoID
			} else {
				return music.id == music.id
			}

		})) != nil) {
			return true
		}

		return false
	}

	func isFavoritedMusic(music: MusicModel) -> Bool {
		if music.sourceType == .offline {
			if favouritePlaylist()?.musics.first(where: { $0.id == music.id }) != nil {
				return true
			}
			return false
		} else {
			if favouritePlaylist()?.musics.first(where: { $0.videoID == music.videoID }) != nil {
				return true
			}
			return false
		}
	}

	func saveImportedMusic(name: String, duration: Double, artist: String?,
						   type: MusicType, sourceType: MusicSourceType = .offline,
						   thumbnail: String?, relativePath: String) -> String? {

		let music = MusicModel()
		music.name = name
		music.durationDouble = duration
		music.artist = artist
		music.type = type
		music.sourceType = sourceType
		music.creationDate = Date().timeIntervalSince1970
		music.relativePath = relativePath
		music.thumbnailURL = thumbnail

		guard let realm = realmObj(), let playlist = importPlaylist() else { return nil }
		do {
			try realm.write {
				realm.add(music)
				playlist.musics.append(music)
			}
			return music.id
		} catch {
			return nil
		}
	}

	func updateMusicThumbnail(_ thumbnail: String?, musicId: String) {
		guard let realm = realmObj() else { return }
		let music = realm.object(ofType: MusicModel.self, forPrimaryKey: musicId)
		try? realm.write {
			music?.thumbnailURL = thumbnail
		}
	}
}
