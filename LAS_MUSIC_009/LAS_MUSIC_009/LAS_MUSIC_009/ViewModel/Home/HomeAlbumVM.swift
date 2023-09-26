//
//  HomeAlbumVM.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 31/08/2023.
//

import Foundation

class HomeAlbumVM {

	var albums: [YTAblumModel] = []
	var onGetAlbums: (() -> Void)?

	func getAllAlbums() {
		guard let artists = Array(DEFAULT_ARTISTS.shuffled().prefix(upTo: 20)) as? [String] else {return}
		YTMManager.shared.getAlbums(artists: artists) { [weak self] albums in
            self?.albums = albums
            self?.onGetAlbums?()
		}
	}

	func getAlbumDetail(album: YTAblumModel, completion: @escaping (_ tracks: [MusicModel]) -> Void) {
		YTMManager.shared.getAlbumDetail(album: album) { ytmusics in
			let musics = ConvertService.shared.convertArrYTSearchToArrMSModel(ytSearchs: ytmusics)
			completion(musics)
		}
	}
}
