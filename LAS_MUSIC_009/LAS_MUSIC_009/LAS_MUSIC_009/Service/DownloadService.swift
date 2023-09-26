//
//  DownloadService.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 26/09/2023.
//

import Foundation

class DownloadService {
    
    static let shared = DownloadService()
    
    func downloadMusic(url: URL,
                  music: MusicModel,
                  completion: @escaping (Bool) -> Void) {
        
        guard let outputUrl = URL.importFolder()?.appendingPathComponent("\(music.videoID ?? "").mp4", isDirectory: true) else {
            completion(false)
            return
        }
        
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            completion(false)
            return
        }
        
        let request = URLRequest(url: url)
        URLSession.shared.downloadTask(with: request) { (tempLocalUrl, response, error) in
            DispatchQueue.main.async {
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    
                     do {
                         try FileManager.default.copyItem(at: tempLocalUrl, to: outputUrl)
                         RealmService.shared.saveObject(music)
                         let relativePath = outputUrl.path.replacingOccurrences(of: "\(URL.document().path)/", with: "")
                         RealmService.shared.saveImportedMusic(name: music.name, duration: music.durationDouble, artist: nil, type: .video, thumbnail: music.thumbnailURL, relativePath: relativePath)
                         completion(true)
                     } catch {
                         completion(false)
                     }

                 } else {
                     completion(false)
                 }
            }

        }.resume()
        
    }
    
}
