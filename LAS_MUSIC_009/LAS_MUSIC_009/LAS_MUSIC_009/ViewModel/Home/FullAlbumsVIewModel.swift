//
//  FullAlbumsVIewModel.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 28/08/2023.
//

import Foundation


import UIKit

class FullAlbumsVIewModel {
    
    var albums: [YTAblumModel] = []
    var bindingViewModel: (() -> Void)?
    
    var numbersCell: Int {
        return albums.count
    }
    
    func albumForCell(at indexPath: IndexPath) -> YTAblumModel {
        return albums[indexPath.row]
    }
    
    
    func loadData() {
        YTMManager.shared.getAlbums(artists: DEFAULT_ARTISTS) { albums in
            self.albums = albums

            self.bindingViewModel?()
        }
    }
    
}
