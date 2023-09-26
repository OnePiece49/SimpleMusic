//
//  YTMModels.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 28/08/2023.
//

import Foundation

// MARK: - Search Response
struct YTSearchResponse: Codable {
	let contents: SearchContents?
	let continuationContents: SearchContinuationContents?
}

struct SearchContents: Codable {
	let tabbedSearchResultsRenderer: ResultsRenderer?
}

// MARK: - Browse Response
struct YTBrowseResponse: Codable {
	let contents: BrowseContents?
	let continuationContents: BrowseContinuationContents?
}

struct BrowseContents: Codable {
	let singleColumnBrowseResultsRenderer: ResultsRenderer?
}

// MARK: - Common
struct ResultsRenderer: Codable {
	let tabs: [Tab]?
}

struct Tab: Codable {
	let tabRenderer: TabRenderer?
}

struct TabRenderer: Codable {
	let content: TabRendererContent?
}

struct TabRendererContent: Codable {
	let sectionListRenderer: SectionListRenderer?
}

struct SectionListRenderer: Codable {
	let contents: [SectionListRendererContent]?
}

struct SectionListRendererContent: Codable {
	let gridRenderer: GridRenderer?
	let musicShelfRenderer: MusicShelfRenderer?
	let musicCarouselShelfRenderer: MusicCarouselShelfRenderer?
	let musicPlaylistShelfRenderer: MusicPlaylistShelfRenderer?
}

// MARK: - GridRenderer
struct GridRenderer: Codable {
	let items: [GridRendererItem]?
}

struct GridRendererItem: Codable {
	let musicNavigationButtonRenderer: MusicNavigationButtonRenderer?
	let musicTwoRowItemRenderer: MusicTwoRowItemRenderer?
}

struct MusicNavigationButtonRenderer: Codable {
	let buttonText: Title?
	let clickCommand: ClickCommand?
}

struct ClickCommand: Codable {
	let clickTrackingParams: String?
	let browseEndpoint: BrowseEndpoint?
}

// MARK: - MusicShelfRenderer
struct MusicShelfRenderer: Codable {
	let contents: [MusicShelfRendererContent]?
	let continuations: [Continuation]?
}

struct MusicShelfRendererContent: Codable {
	let musicTwoColumnItemRenderer: MusicTwoColumnItemRenderer?
}

struct MusicTwoColumnItemRenderer: Codable {
	let thumbnail: MusicItemThumbnailRenderer?
	let title: Title?
	let subtitle: Title?
	let navigationEndpoint: NavigationEndpoint?
}

// MARK: - MusicCarouselShelfRenderer
struct MusicCarouselShelfRenderer: Codable {
	let contents: [MusicCarouselShelfRendererContent]?
}

struct MusicCarouselShelfRendererContent: Codable {
	let musicTwoRowItemRenderer: MusicTwoRowItemRenderer?
	let musicTwoColumnItemRenderer: MusicTwoColumnItemRenderer?
}

struct MusicTwoRowItemRenderer: Codable {
	let thumbnailRenderer: MusicItemThumbnailRenderer?
	let title: Title?
	let subtitle: Title?
	let navigationEndpoint: NavigationEndpoint?
}

// MARK: - MusicPlaylistShelfRenderer
struct MusicPlaylistShelfRenderer: Codable {
	let playlistId: String?
	let contents: [MusicShelfRendererContent]?
	let continuations: [Continuation]
}

//struct MusicPlaylistShelfRendererContent: Codable {
//	let musicTwoColumnItemRenderer: MusicTwoColumnItemRenderer?
//}

// MARK: - Title
struct Title: Codable {
	let runs: [Run]?
}

struct Run: Codable {
	let text: String?
}

// MARK: - Endpoint
struct NavigationEndpoint: Codable {
	let watchEndpoint: WatchEndpoint?
	let browseEndpoint: BrowseEndpoint?
}

struct WatchEndpoint: Codable {
	let videoId: String?
	let playlistId: String?
}

struct BrowseEndpoint: Codable {
	let browseId: String?
	let params: String?
}

// MARK: - Thumbnail
struct MusicItemThumbnailRenderer: Codable {
	let musicThumbnailRenderer: MusicThumbnailRenderer?
}

struct MusicThumbnailRenderer: Codable {
	let thumbnail: ThumbnailRenderer?
}

struct ThumbnailRenderer: Codable {
	let thumbnails: [Thumbnail]?
}

struct Thumbnail: Codable {
	let url: String?
	let width: Int?
	let height: Int?
}

// MARK: - Continuation
struct SearchContinuationContents: Codable {
	let musicShelfContinuation: MusicShelfRenderer?
}

struct BrowseContinuationContents: Codable {
	let musicPlaylistShelfContinuation: MusicShelfRenderer?
}

struct Continuation: Codable {
	let nextContinuationData: NextContinuationData?
}

struct NextContinuationData: Codable {
	let continuation: String?
}
