//
//  AddToPlaylistTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 16/08/2023.
//

import UIKit
import SDWebImage

class AddToPlaylistTBCell: BaseMyFileTBCell {
    
    var playlist: PlaylistModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let playlist = playlist else {return}
        
        self.moreButton.isHidden = true
        self.nameLbl.text = playlist.name
        self.durationOrCountLbl.text = (playlist.musics.count <= 1) ? "\(playlist.musics.count) music" : "\(playlist.musics.count) musics"
        self.thumbnailImv.sd_setImage(with: URL(string: playlist.musics.first?.thumbnailURL ?? ""), placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default), context: .none)
    }
    
}
