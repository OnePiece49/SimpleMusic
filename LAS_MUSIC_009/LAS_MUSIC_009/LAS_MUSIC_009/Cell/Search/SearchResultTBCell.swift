//
//  SearchResultCLCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 22/08/2023.
//

import UIKit
import SDWebImage


protocol SearchResultTBCellDelegate: AnyObject {
    func didSelectMore(_ cell: SearchResultTBCell)
}

class SearchResultTBCell: BaseMyFileTBCell {

    weak var delegate: SearchResultTBCellDelegate?

    var musicModel: MusicModel? {
        didSet {
            let thumbnailURL = URL(string: musicModel?.thumbnailURL ?? "")
            thumbnailImv.sd_setImage(with: thumbnailURL,
                                     placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default),
                                     context: .none)
            nameLbl.text = musicModel?.name
            durationOrCountLbl.text = musicModel?.artist
        }
    }

    override func moreButtonTapped() {
        delegate?.didSelectMore(self)
    }
}
