//
//  MusicModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 14/08/2023.
//

import Foundation
import RealmSwift

enum MusicType: String, PersistableEnum {
	case audio, video
}

enum MusicSourceType: String, PersistableEnum {
	case offline, online
}

class MusicModel: Object {

	@Persisted(primaryKey: true) var id: String = UUID().uuidString
	@Persisted var name: String = ""
	@Persisted var durationDouble: Double = 0
    @Persisted var durationString: String?
	@Persisted var isFavorited: Bool = false

	@Persisted var artist: String?
	@Persisted var type: MusicType?
	@Persisted var sourceType: MusicSourceType?
    @Persisted var creationDate: TimeInterval?
    
	/// for locally
	@Persisted var relativePath: String?
    /// for online media
	@Persisted var videoID: String?
	@Persisted var thumbnailURL: String?

	/// for locally
	var absolutePath: URL? {
		if let path = relativePath {
			return URL.document().appendingPathComponent(path)
		}
		return nil
	}

	/// online
	var remotePath: URL? {
		if let videoID = videoID {
			let urlString = YT_WATCH_URL + videoID
			return URL(string: urlString)
		}
		return nil
	}
}
