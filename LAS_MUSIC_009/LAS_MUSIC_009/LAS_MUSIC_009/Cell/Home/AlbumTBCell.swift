//
//  AlbumTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 28/08/2023.
//

import UIKit

import SDWebImage

class AlbumTBCell: BaseMyFileTBCell {
    
    var album: YTAblumModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let album = album else {return}
        
        self.moreButton.isHidden = true
        self.nameLbl.text = album.title
        self.durationOrCountLbl.text = album.artist
        self.thumbnailImv.sd_setImage(with: URL(string: album.thumbnail ?? ""), placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default), context: .none)
    }
    
}
