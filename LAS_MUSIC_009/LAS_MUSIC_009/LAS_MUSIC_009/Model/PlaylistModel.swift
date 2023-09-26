//
//  PlaylistModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 14/08/2023.
//

import Foundation
import RealmSwift

class PlaylistModel: Object {

	@Persisted(primaryKey: true) var id: String = UUID().uuidString
	@Persisted var name: String = ""
	@Persisted var creationDate: TimeInterval = 0
	@Persisted var musics: List<MusicModel> = List()

}
