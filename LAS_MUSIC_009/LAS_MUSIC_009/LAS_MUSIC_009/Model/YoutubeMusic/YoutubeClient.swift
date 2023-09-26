//
//  YoutubeClient.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 25/08/2023.
//

import Foundation

struct YoutubeClient {
	var clientName: String
	var clientVersion: String
	var gl: String
	var hl: String

	static func iosClient() -> YoutubeClient {
		let gl = Locale.current.regionCode ?? "US"
		let hl = Locale.preferredLanguages.first?.split(separator: "-").first ?? "en"

		return YoutubeClient(clientName: CLIENT_NAME,
							 clientVersion: CLIENT_VERSION,
							 gl: gl, hl: String(hl))
	}
}
