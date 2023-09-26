//
//  GGDriveTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 14/08/2023.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import AVFoundation

class GGDriveTBCell: BaseImportTBCell {
    
    var file: GTLRDrive_File? {
        didSet {
            updateUI()
        }
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(truncating: file?.size ?? 0), countStyle: .file)
    }
    
    private func updateUI() {
        guard let file = file else {return}
        self.nameLbl.text = file.name
        
        if let duration = file.videoMediaMetadata?.durationMillis as? Int {
            let durationSeconds = duration / 1000
            
            let time = CMTime(seconds: Double(durationSeconds), preferredTimescale: CMTimeScale(1.0)).getTimeString()
            self.fileSizeLbl.text = time
        } else {
            self.fileSizeLbl.text = fileSizeString
        }
        
    }
}

