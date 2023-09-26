//
//  YTLocalModel.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 25/08/2023.
//

import Foundation

struct YTMusicModel {
	var videoId: String?
	var thumnailUrl: String?
	var videoTitle: String?
	var duration: String?
	var artist: String?
}

struct YTAblumModel {
	var browseId: String?
	var title: String?
	var artist: String?
	var thumbnail: String?
}

struct YTGenresModel {
	var title: String?
	var params: String?
}
