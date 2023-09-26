//
//  APIRequest.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 25/08/2023.
//

import Foundation

protocol APIRequest: AnyObject {
	func makeRequest<T: Codable>(type: T.Type, request: URLRequest, completion: @escaping (T?) -> Void)
}

extension APIRequest {
	func makeRequest<T: Codable>(type: T.Type, request: URLRequest, completion: @escaping (T?) -> Void) {
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				DispatchQueue.main.async { completion(nil) }
				return
			}

			guard let httpResponse = response as? HTTPURLResponse,
				  (200...299).contains(httpResponse.statusCode) else {
				DispatchQueue.main.async { completion(nil) }
				return
			}

			do {
				let response = try JSONDecoder().decode(T.self, from: data)
				DispatchQueue.main.async { completion(response) }

			} catch {
				DispatchQueue.main.async { completion(nil) }
			}
		}.resume()
	}
}
