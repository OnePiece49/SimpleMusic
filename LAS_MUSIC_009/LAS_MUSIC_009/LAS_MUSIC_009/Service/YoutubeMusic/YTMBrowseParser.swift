//
//  YTMBrowseParser.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 25/08/2023.
//

import Foundation

struct YTMBrowseParser {

	private var response: YTBrowseResponse
	private var musicRenderer: MusicShelfRenderer?

	init(response: YTBrowseResponse) {
		self.response = response
		self.musicRenderer = response.contents?.singleColumnBrowseResultsRenderer?
			.tabs?.first?.tabRenderer?.content?.sectionListRenderer?
			.contents?.first?.musicShelfRenderer
	}

	func getAllMusics(album: YTAblumModel) -> [YTMusicModel]? {
		guard let contents = musicRenderer?.contents else { return nil }
		var musics: [YTMusicModel] = []

		for content in contents {
			let model = toMusicModel(musicToColumn: content.musicTwoColumnItemRenderer, album: album)
			musics.append(model)
		}
		return musics
	}

	// MARK: - Private
	private func toMusicModel(musicToColumn: MusicTwoColumnItemRenderer?, album: YTAblumModel) -> YTMusicModel {
		let videoId = musicToColumn?.navigationEndpoint?.watchEndpoint?.videoId
		let title = musicToColumn?.title?.runs?.first?.text
		let duration = musicToColumn?.subtitle?.runs?.last?.text

		return YTMusicModel(videoId: videoId, thumnailUrl: album.thumbnail,
							videoTitle: title, duration: duration, artist: album.artist)
	}

}
