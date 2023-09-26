//
//  ConvertAudioManager.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 17/08/2023.
//

import Foundation
import ffmpegkit

class ConvertAudioManager {
    
    static let shared = ConvertAudioManager()
    
    func convertAudio(inputUrl: URL,
                      type: ConvertAudioType,
                      completion: @escaping((_ success: Bool, _ output: URL?) -> Void)) {
        
        let input = inputUrl
        let outputString = input.deletingPathExtension().lastPathComponent
        guard let output = URL.audioFolder()?.appendingPathComponent(outputString).appendingPathExtension(type.pathExtension) else {
            completion(false, nil)
            return
        }
        
        FFmpegKit.executeAsync("-i \(inputUrl.path) \(output.path)") { session in
             guard let session = session else {
                 completion(false, nil)
                 return
             }
             guard let returnCode = session.getReturnCode() else {
                 completion(false, nil)
                 return
             }
            
            if ReturnCode.isSuccess(returnCode) {
                completion(true, output)
            } else {
                completion(false, nil)
            }
         }
    }
    

    
}
