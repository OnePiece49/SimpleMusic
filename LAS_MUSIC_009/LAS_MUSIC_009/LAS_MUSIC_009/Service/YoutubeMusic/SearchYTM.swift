//
//  SearchYTM.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 25/08/2023.
//

import Foundation

typealias SearchResultCompletion = (_ ytModels: [YTMusicModel]?, _ token: String?) -> Void

enum YTSearchFilter {
	case music, mv, album

	var params: String {
		switch self {
			case .music: return "EgWKAQIIAWoKEAkQBRAKEAMQBA%3D%3D"
			case .mv: return "EgWKAQIQAWoKEAkQChAFEAMQBA%3D%3D"
			case .album: return "EgWKAQIYAWoKEAkQChAFEAMQBA%3D%3D"
		}
	}
}

protocol SearchYTM: APIRequest {
	func search(query: String, filter: YTSearchFilter, completion: @escaping SearchResultCompletion)
	func searchContinuation(filter: YTSearchFilter, token: String, completion: @escaping SearchResultCompletion)
}

extension SearchYTM {
	func search(query: String,
				filter: YTSearchFilter,
				completion: @escaping SearchResultCompletion) {

		let body: [String: Any] = [
			"query": query,
			"params": filter.params
		]

		let endpoint = YTMEndPoint(baseURL: YTM_BASE_SEARCH_URL, body: body)

		guard let request = endpoint.getURLRequest() else {
			completion(nil, nil)
			return
		}

		self.makeRequest(type: YTSearchResponse.self, request: request) { response in
			guard let response = response else {
				completion(nil, nil)
				return
			}
			let searchParser = YTMSearchParser(response: response, filter: filter)
			completion(searchParser.getAllMusics(),
					   searchParser.getContinuationToken())
		}
	}

	func searchContinuation(filter: YTSearchFilter,
							token: String,
							completion: @escaping SearchResultCompletion) {

		let queryItems: [URLQueryItem] = [
			.init(name: "key", value: YTM_KEY),
			.init(name: "ctoken", value: token),
			.init(name: "continuation", value: token),
			.init(name: "type", value: "next"),
		]

		let endpoint = YTMEndPoint(baseURL: YTM_BASE_SEARCH_URL, queryItems: queryItems, body: [:])

		guard let request = endpoint.getURLRequest() else {
			completion(nil, nil)
			return
		}

		self.makeRequest(type: YTSearchResponse.self, request: request) { response in
			guard let response = response else {
				completion(nil, nil)
				return
			}
			let searchParser = YTMSearchParser(response: response, filter: filter)
			completion(searchParser.getAllMusics(),
					   searchParser.getContinuationToken())
		}
	}

}
