//
//  ExploreYTM.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 25/08/2023.
//

import Foundation

typealias ChartsGetResult = (musicChart: [YTMusicModel], trending: [YTMusicModel])

protocol ExploreYTM: APIRequest {
	func getAllGenres(completion: @escaping (_ genres: [YTGenresModel])-> Void)
	func getGenresPLaylistDetail(params: String, completion: @escaping SearchResultCompletion)
	func getContinuationGenresPLaylistDetail(token: String, completion: @escaping SearchResultCompletion)
	func getMusicChart(completion: @escaping (ChartsGetResult) -> Void)
}

extension ExploreYTM {

	// MARK: - Public
	func getAllGenres(completion: @escaping (_ genres: [YTGenresModel])-> Void) {
		let body: [String: Any] = ["browseId": GENRES_BROWSE_ID]

		let endpoint = YTMEndPoint(baseURL: YTM_BASE_BROWSE_URL, body: body)

		guard let request = endpoint.getURLRequest() else {
			completion([])
			return
		}

		self.makeRequest(type: YTBrowseResponse.self, request: request) { response in
			guard let response = response else {
				completion([])
				return
			}

			let exploreParser = YTMExploreParser(response: response)
			let genres = exploreParser.getAllGenres()
			completion(genres)
		}
	}

	func getGenresPLaylistDetail(params: String, completion: @escaping SearchResultCompletion) {
		self.getPlaylistBrowseId(params: params) { [weak self] browseId in
			guard let self = self, let browseId = browseId else {
				completion(nil, nil)
				return
			}

			let body: [String: Any] = ["browseId": browseId]
			let endpoint = YTMEndPoint(baseURL: YTM_BASE_BROWSE_URL, body: body)

			guard let request = endpoint.getURLRequest() else {
				completion(nil, nil)
				return
			}

			self.makeRequest(type: YTBrowseResponse.self, request: request) { response in
				guard let response = response else {
					completion(nil, nil)
					return
				}

				let exploreParser = YTMExploreParser(response: response)
				completion(exploreParser.getMusics(), exploreParser.getContinuationToken())
			}
		}
	}

	func getContinuationGenresPLaylistDetail(token: String, completion: @escaping SearchResultCompletion) {
		let queryItems: [URLQueryItem] = [
			.init(name: "key", value: YTM_KEY),
			.init(name: "ctoken", value: token),
			.init(name: "continuation", value: token),
			.init(name: "type", value: "next")
		]

		let endpoint = YTMEndPoint(baseURL: YTM_BASE_BROWSE_URL, queryItems: queryItems, body: [:])

		guard let request = endpoint.getURLRequest() else {
			completion(nil, nil)
			return
		}

		self.makeRequest(type: YTBrowseResponse.self, request: request) { response in
			guard let response = response else {
				completion(nil, nil)
				return
			}

			let exploreParser = YTMExploreParser(response: response)
			completion(exploreParser.getMusics(), exploreParser.getContinuationToken())
		}
	}

	func getMusicChart(completion: @escaping (ChartsGetResult) -> Void) {
		let body: [String: Any] = [
			"browseId": "FEmusic_charts",
			"formData": [
				"selectedValues": ["US"]
			]
		]
		let endpoint = YTMEndPoint(baseURL: YTM_BASE_BROWSE_URL, body: body)

		guard let request = endpoint.getURLRequest() else {
			completion(([], []))
			return
		}

		self.makeRequest(type: YTBrowseResponse.self, request: request) { response in
			guard let response = response else {
				completion(([], []))
				return
			}

			let exploreParser = YTMExploreParser(response: response)
			let charts = exploreParser.getCharts()
			completion(charts)
		}
	}

	// MARK: - Private
	private func getPlaylistBrowseId(params: String, completion: @escaping (_ browseId: String?)-> Void) {
		let body: [String: Any] = [
			"browseId": GENRES_SPECIFIC_BROWSE_ID,
			"params": params
		]

		let endpoint = YTMEndPoint(baseURL: YTM_BASE_BROWSE_URL, body: body)

		guard let request = endpoint.getURLRequest() else {
			completion(nil)
			return
		}

		self.makeRequest(type: YTBrowseResponse.self, request: request) { response in
			guard let response = response else {
				completion(nil)
				return
			}

			let exploreParser = YTMExploreParser(response: response)
			let browseId = exploreParser.getFirstPLaylistBrowseId()
			completion(browseId)
		}
	}

}
