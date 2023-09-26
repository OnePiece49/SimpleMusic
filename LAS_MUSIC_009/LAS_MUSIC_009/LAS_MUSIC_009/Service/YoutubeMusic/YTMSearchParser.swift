//
//  YTMSearchParser.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 25/08/2023.
//

import Foundation

struct YTMSearchParser {

	private let response: YTSearchResponse
	private let filter: YTSearchFilter
	private var musicRenderer: MusicShelfRenderer?
	private var continuation: Continuation?

	init(response: YTSearchResponse, filter: YTSearchFilter) {
		self.response = response
		self.filter = filter

		if response.contents != nil {
			self.musicRenderer = response.contents?
				.tabbedSearchResultsRenderer?.tabs?.first?.tabRenderer?
				.content?.sectionListRenderer?.contents?.first?.musicShelfRenderer
			self.continuation = musicRenderer?.continuations?.first

		} else if response.continuationContents != nil {
			self.musicRenderer = response.continuationContents?.musicShelfContinuation
			self.continuation = musicRenderer?.continuations?.first
		}
	}

	// MARK: - Public
	func getAllMusics() -> [YTMusicModel] {
		guard let contents = musicRenderer?.contents, filter != .album else { return [] }
		var musics = [YTMusicModel]()

		for content in contents {
			let model = toMusicModel(musicTwoColumn: content.musicTwoColumnItemRenderer)
			musics.append(model)
		}
		return musics
	}

	func getFirstAlbum() -> YTAblumModel? {
		guard filter == .album else { return nil }
		let musicTwoColumn = musicRenderer?.contents?.first?.musicTwoColumnItemRenderer
		let browseId = getBrowseId(musicTwoColumn)
		let title = getTitle(musicTwoColumn)
		let artist = getArtist(musicTwoColumn)
		let thumbnail = getThumnailUrl(musicTwoColumn)
		return YTAblumModel(browseId: browseId, title: title, artist: artist, thumbnail: thumbnail)
	}

	func getContinuationToken() -> String? {
		guard let continuation = continuation else { return nil }
		return continuation.nextContinuationData?.continuation
	}

	// MARK: - Private
	private func toMusicModel(musicTwoColumn: MusicTwoColumnItemRenderer?) -> YTMusicModel {
		let videoId = getVideoId(musicTwoColumn)
		let thumnailUrl = getThumnailUrl(musicTwoColumn)
		let title = getTitle(musicTwoColumn)
		let duration = getDuration(musicTwoColumn)
		let artist = getArtist(musicTwoColumn)
		return YTMusicModel(videoId: videoId, thumnailUrl: thumnailUrl,
							videoTitle: title, duration: duration, artist: artist)
	}

	private func getTitle(_ musicTwoColumn: MusicTwoColumnItemRenderer?) -> String? {
		return musicTwoColumn?.title?.runs?.first?.text
	}

	private func getArtist(_ musicTwoColumn: MusicTwoColumnItemRenderer?) -> String? {
		if filter == .album {
			return musicTwoColumn?.subtitle?.runs?.last?.text
		} else {
			return musicTwoColumn?.subtitle?.runs?.first?.text
		}
	}

	private func getThumnailUrl(_ musicTwoColumn: MusicTwoColumnItemRenderer?) -> String? {
		return musicTwoColumn?.thumbnail?.musicThumbnailRenderer?.thumbnail?.thumbnails?.last?.url
	}

	private func getDuration(_ musicTwoColumn: MusicTwoColumnItemRenderer?) -> String? {
		if filter == .music {
			return musicTwoColumn?.subtitle?.runs?.last?.text
		}
		return nil
	}

	private func getVideoId(_ musicTwoColumn: MusicTwoColumnItemRenderer?) -> String? {
		return musicTwoColumn?.navigationEndpoint?.watchEndpoint?.videoId
	}

	private func getBrowseId(_ musicTwoColumn: MusicTwoColumnItemRenderer?) -> String? {
		if filter == .album {
			return musicTwoColumn?.navigationEndpoint?.browseEndpoint?.browseId
		}
		return nil
	}

}
