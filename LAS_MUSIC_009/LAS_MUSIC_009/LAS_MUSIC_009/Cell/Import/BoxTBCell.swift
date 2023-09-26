//
//  BoxTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 15/08/2023.
//

import UIKit
import BoxSDK

class BoxTBCell: BaseImportTBCell {
    
    var file: File? {
        didSet {
            updateUI()
        }
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(truncating: (file?.size ?? 0) as NSNumber), countStyle: .file)
    }
    
    private func updateUI() {
        guard let file = file else {return}
        
        self.nameLbl.text = file.name
        self.fileSizeLbl.text = fileSizeString
    }
}

