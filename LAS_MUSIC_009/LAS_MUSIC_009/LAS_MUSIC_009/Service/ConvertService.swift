//
//  ConvertService.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 22/08/2023.
//

import UIKit
import RealmSwift

class ConvertService {
    static let shared = ConvertService()
    
    func convertYTSearchToMSModel(ytSearch: YTMusicModel) -> MusicModel {
        let music = MusicModel()
        music.sourceType = .online
        music.name = ytSearch.videoTitle ?? "Updating"
        music.videoID = ytSearch.videoId
        music.durationString = ytSearch.duration
        music.artist = ytSearch.artist
        music.thumbnailURL = ytSearch.thumnailUrl
        music.creationDate = Date().timeIntervalSince1970
        music.type = .video
        return music
    }
    
    func convertArrYTSearchToArrMSModel(ytSearchs: [YTMusicModel]) -> [MusicModel] {
        var musics: [MusicModel] = []
        ytSearchs.forEach { youtube in
            let music = self.convertYTSearchToMSModel(ytSearch: youtube)
            musics.append(music)
        }
    
        return musics
    }

	func convertAndCheckMusicModels(ytModels: [YTMusicModel]) -> [MusicModel] {
		guard let realm = RealmService.shared.realmObj() else { return [] }

		let online = realm.objects(MusicModel.self).where { music in
			return music.sourceType.equals(.online)
		}

		let onlineMusics = Set(online.map { $0.videoID })
		let allMusics = Set(ytModels.map { $0.videoId })
		let intersection = allMusics.intersection(onlineMusics)

		var musics: [MusicModel] = []

		ytModels.forEach { youtube in
			var music = MusicModel()
			if intersection.contains(youtube.videoId) {
				if let ms = online.where({ $0.videoID == youtube.videoId }).first {
					music = ms
				}
			} else {
				music = convertYTSearchToMSModel(ytSearch: youtube)
			}
			musics.append(music)
		}

		return musics
	}
}
