//
//  YTMEndPoint.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 25/08/2023.
//

import Foundation

enum HTTPMethod: String {
	case post = "POST"
}

struct YTMEndPoint {
	var baseURL: String
	var httpMethod: HTTPMethod
	var	queryItems: [URLQueryItem]
	var header: [String : String]
	var body: [String : Any]

	init(baseURL: String,
		 httpMethod: HTTPMethod = .post,
		 queryItems: [URLQueryItem] = [URLQueryItem(name: "key", value: YTM_KEY)],
		 header: [String : String] = DEFAULT_HTTP_HEADER,
		 body: [String : Any]) {

		self.baseURL = baseURL
		self.httpMethod = httpMethod
		self.queryItems = queryItems
		self.header = header
		self.body = body
	}

	func getURLRequest() -> URLRequest? {
		guard let baseUrl = URL(string: baseURL),
			  let finalUrl = baseUrl.appendingQuerys(queryItems) else { return nil }
		return constructRequest(httpMethod: httpMethod, url: finalUrl, header: header, body: updateBody())
	}

	private func initBody() -> [String: Any] {
		let client = YoutubeClient.iosClient()
		return [
			"context": [
				"client": [
					"gl": "VN" ,
					"hl": "vi" ,
					"clientName": client.clientName,
					"clientVersion": client.clientVersion
				]
			]
		]
	}

	private func updateBody() -> [String: Any] {
		let context = initBody()
		return body.merging(context) { current, new in new }
	}

	private func constructRequest(httpMethod: HTTPMethod,
								  url: URL,
								  header: [String: String],
								  body: [String: Any]) -> URLRequest? {

		guard let data = try? JSONSerialization.data(withJSONObject: body, options: []) else { return nil }
		var request = URLRequest(url: url)
		request.httpMethod = httpMethod.rawValue
		request.allHTTPHeaderFields = header
		request.httpBody = data
		return request
	}

}
