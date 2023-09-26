//
//  BrowseYTM.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 25/08/2023.
//

import Foundation

protocol BrowseYTM: APIRequest {
	func getAlbums(artists: [String], completion: @escaping (_ albums: [YTAblumModel]) -> Void)
	func getAlbumDetail(album: YTAblumModel, completion: @escaping (_ tracks: [YTMusicModel]) -> Void)
}

extension BrowseYTM {

	// MARK: - Public
	func getAlbums(artists: [String], completion: @escaping (_ albums: [YTAblumModel]) -> Void) {
		let dispatchGroup = DispatchGroup()
		var albums = [YTAblumModel]()

		for artist in artists {
			dispatchGroup.enter()
			self.getArtistAlbum(query: artist) { album in
				if let album = album {
					albums.append(album)
				}
				dispatchGroup.leave()
			}
		}

		dispatchGroup.notify(queue: .main) {
			completion(albums)
		}
	}

	func getAlbumDetail(album: YTAblumModel,
						completion: @escaping (_ tracks: [YTMusicModel]) -> Void) {

		let body: [String: Any] = ["browseId": album.browseId as Any]
		let endpoint = YTMEndPoint(baseURL: YTM_BASE_BROWSE_URL, header: DEFAULT_HTTP_HEADER, body: body)

		guard let request = endpoint.getURLRequest() else {
			completion([])
			return
		}

		self.makeRequest(type: YTBrowseResponse.self, request: request) { response in
			guard let response = response else {
				completion([])
				return
			}

			let browseParser = YTMBrowseParser(response: response)
			guard let tracks = browseParser.getAllMusics(album: album) else {
				completion([])
				return
			}
			completion(tracks)
		}
	}

	// MARK: - Private
	private func getArtistAlbum(query: String,
								completion: @escaping (_ album: YTAblumModel?) -> Void) {

		let params = YTSearchFilter.album.params
		let body: [String: Any] = [
			"query": query,
			"params": params
		]

		let endpoint = YTMEndPoint(baseURL: YTM_BASE_SEARCH_URL, header: DEFAULT_HTTP_HEADER, body: body)

		guard let request = endpoint.getURLRequest() else {
			completion(nil)
			return
		}

		self.makeRequest(type: YTSearchResponse.self, request: request) { response in
			guard let response = response else {
				completion(nil)
				return
			}
			let searchParser = YTMSearchParser(response: response, filter: .album)
			let album = searchParser.getFirstAlbum()
			completion(album)
		}
	}
}
