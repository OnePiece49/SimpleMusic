//
//  HomeDetailViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 28/08/2023.
//

import Foundation


class AlbumDetailViewModel {
    
    let album: YTAblumModel
    var musics: [MusicModel] = []
    
    var bindingViewModel: (() -> Void)?
    
    var numberCells: Int {
        return musics.count
    }
    
    func musicForCell(at indexPath: IndexPath) -> MusicModel {
        return musics[indexPath.row]
    }
    
    func loadData() {
        YTMManager.shared.getAlbumDetail(album: album) { ytmusics in
            
            self.musics = ConvertService.shared.convertArrYTSearchToArrMSModel(ytSearchs: ytmusics)
            self.bindingViewModel?()
        }
    }
    
    func getCurrentPlaylist() {
        let playList = PlaylistModel()
        
    }
    
    init(album: YTAblumModel) {
        self.album = album
       
    }
}
