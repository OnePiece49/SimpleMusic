//
//  AudioConvertedTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 17/08/2023.
//

import UIKit

class AudioConvertedTBCell: BaseMyFileTBCell {
    
    var onSelectMoreBtn: ((_ cell: AudioConvertedTBCell) -> Void)?

    var music: MusicModel? {
        didSet {
            thumbnailImv.contentMode = .center
            thumbnailImv.backgroundColor = UIColor(rgb: 0xABFF2D)
            thumbnailImv.image = UIImage(named: AssetConstant.ic_audio_converted)?.withRenderingMode(.alwaysOriginal)
            nameLbl.text = music?.name
            durationOrCountLbl.text = music?.durationDouble.toString()
        }
    }

    override func moreButtonTapped() {
        onSelectMoreBtn?(self)
    }
    
}
//MARK: - delegate

