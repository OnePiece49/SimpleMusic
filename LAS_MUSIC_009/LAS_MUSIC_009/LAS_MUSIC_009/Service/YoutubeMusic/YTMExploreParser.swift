//
//  YTMExploreParser.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 25/08/2023.
//

import Foundation

struct YTMExploreParser {

	enum ResultType {
		case allGenres, genresDetail, playlistBrowseId
	}

	private let response: YTBrowseResponse
//	private let resultType: ResultType
	private var sectionListRenderer: SectionListRenderer?

	init(response: YTBrowseResponse) {
		self.response = response
//		self.resultType = resultType

		sectionListRenderer = response.contents?.singleColumnBrowseResultsRenderer?
			.tabs?.first?.tabRenderer?.content?.sectionListRenderer
	}

	// MARK: - Public

	func getAllGenres() -> [YTGenresModel] {
		var genres = [YTGenresModel]()
		if let items = sectionListRenderer?.contents?.last?.gridRenderer?.items {
			for item in items {
				let title = item.musicNavigationButtonRenderer?.buttonText?.runs?.first?.text
				let params = item.musicNavigationButtonRenderer?.clickCommand?.browseEndpoint?.params
				let model = YTGenresModel(title: title, params: params)
				genres.append(model)
			}
		}
		return genres
	}

	func getMusics() -> [YTMusicModel] {
		var musics = [YTMusicModel]()

		var musicContents = [MusicShelfRendererContent]()
		if let contents = sectionListRenderer?.contents?.first?.musicPlaylistShelfRenderer?.contents {
			musicContents = contents
		} else if let contents = response.continuationContents?.musicPlaylistShelfContinuation?.contents {
			musicContents = contents
		}

		for content in musicContents {
			let model = toMusicModel(musicTwoColumn: content.musicTwoColumnItemRenderer, musicTwoRow: nil)
			musics.append(model)
		}

		return musics
	}

	func getCharts() -> ChartsGetResult {
		if let count = sectionListRenderer?.contents?.count, count < 2 { return ([], []) }
		var musicChart = [YTMusicModel]()
		var treding = [YTMusicModel]()

		if let contents = sectionListRenderer?.contents?[1].musicCarouselShelfRenderer?.contents {
			for content in contents {
				let model = toMusicModel(musicTwoColumn: content.musicTwoColumnItemRenderer,
										 musicTwoRow: content.musicTwoRowItemRenderer)
				musicChart.append(model)
			}
		}

		if let contents = sectionListRenderer?.contents?.last?.musicCarouselShelfRenderer?.contents {
			for content in contents {
				let model = toMusicModel(musicTwoColumn: content.musicTwoColumnItemRenderer,
										 musicTwoRow: content.musicTwoRowItemRenderer)
				treding.append(model)
			}
		}

		return (musicChart, treding)
	}

	func getFirstPLaylistBrowseId() -> String? {
		var browseId: String?

		if let gridRenderer = sectionListRenderer?.contents?.first?.gridRenderer {
			browseId = gridRenderer.items?.first?
				.musicTwoRowItemRenderer?.navigationEndpoint?
				.browseEndpoint?.browseId
		} else if let musicCarousel = sectionListRenderer?.contents?.first?.musicCarouselShelfRenderer {
			browseId = musicCarousel.contents?.first?
				.musicTwoRowItemRenderer?.navigationEndpoint?
				.browseEndpoint?.browseId
		}

		return browseId
	}

	func getContinuationToken() -> String? {
		guard let continuation = sectionListRenderer?.contents?
			.first?.musicPlaylistShelfRenderer?.continuations.last else { return nil }
		return continuation.nextContinuationData?.continuation
	}

	// MARK: - Private
	private func toMusicModel(musicTwoColumn: MusicTwoColumnItemRenderer?,
							  musicTwoRow: MusicTwoRowItemRenderer?) -> YTMusicModel {

		var videoId: String?
		var thumnailUrl: String?
		var title: String?
		var duration: String?
		var artist: String?

		if let musicTwoColumn = musicTwoColumn {
			videoId = musicTwoColumn.navigationEndpoint?.watchEndpoint?.videoId
			thumnailUrl = musicTwoColumn.thumbnail?.musicThumbnailRenderer?.thumbnail?.thumbnails?.first?.url
			title = musicTwoColumn.title?.runs?.first?.text
			duration = musicTwoColumn.subtitle?.runs?.last?.text
			artist = musicTwoColumn.subtitle?.runs?.first?.text

		} else if let musicTwoRow = musicTwoRow {
			videoId = musicTwoRow.navigationEndpoint?.watchEndpoint?.videoId
			thumnailUrl = musicTwoRow.thumbnailRenderer?.musicThumbnailRenderer?.thumbnail?.thumbnails?.first?.url
			title = musicTwoRow.title?.runs?.first?.text
			duration = musicTwoRow.subtitle?.runs?.last?.text
			artist = musicTwoRow.subtitle?.runs?.first?.text

		}

		return YTMusicModel(videoId: videoId, thumnailUrl: thumnailUrl,
							videoTitle: title, duration: duration, artist: artist)
	}

}

