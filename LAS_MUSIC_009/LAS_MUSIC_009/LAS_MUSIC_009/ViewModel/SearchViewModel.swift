//
//  SearchViewModel.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 22/08/2023.
//

import UIKit

enum SearchFilter: Int, CaseIterable {
    case music
    case video
    case offline
    
    var title: String {
        switch self {
        case .music:
            return "Music"
        case .video:
            return "Video"
        case .offline:
            return "My file"
        }
    }
}

enum SearchStatus {
    case noSearch
    case willSearching
}

class SearchViewModel {
    
    private let realm = RealmService.shared.realmObj()
    var filter: SearchFilter = .music
    private var tokenMusic: String?
    private var tokenMV: String?
    
    var resultMusic: [MusicModel] = []
    var resultMv: [MusicModel] = []
    var resultImport: [MusicModel] = []
    var importMusics: [MusicModel] = []
    var latestTextSearch = ""
    var historyPlaylist: PlaylistModel?
    
    var bindingSearching: (() -> Void)?
    var bindingLoadmore: (() -> Void)?
    var bindingDidSelectTopHistory: ((MusicModel) -> Void)?

    func filterSelected(filter: SearchFilter?) -> Bool {
        return self.filter == filter
    }
    
    private var hasLoadedMusic = false
    private var hasLoadedMv = false
    private var hasLoadImport = false
    
    var numberCells: Int {
        switch filter {
        case .music:
            return resultMusic.count
        case .video:
            return resultMv.count
        case .offline:
            return resultImport.count
        }
    }
    
    func getPlaylist(at indexPath: IndexPath) -> PlaylistModel? {
        let endIndex = numberCells
        let startIndex = indexPath.row
        var slicedArray: Array<Any>

        switch filter {
        case .music:
            slicedArray = Array(resultMusic[startIndex..<endIndex])
        case .video:
            slicedArray = Array(resultMv[startIndex..<endIndex])
        case .offline:
            slicedArray = Array(resultImport[startIndex..<endIndex])
        }

        guard let musics = Array(slicedArray.prefix(20)) as? [MusicModel] else {return nil}
        
        let playlist = PlaylistModel()
        playlist.musics.append(objectsIn: musics)
        return playlist
    }
    
    
    func musicForCell(at indexPath: IndexPath) -> MusicModel {
        switch filter {
        case .music:
            return resultMusic[indexPath.row]
        case .video:
            return resultMv[indexPath.row]
        case .offline:
            return resultImport[indexPath.row]
        }
    }
    
    func reloadData() {
        switch filter {
        case .music:
            self.tokenMusic = ""
            self.resultMusic = []
        case .video:
            self.tokenMV = ""
            self.resultMv = []
        case .offline:
            self.resultImport = []
        }
    }
    
    var fromYoutube: Bool {
        return filter != .offline
    }
    
    func shoudLoadNewFilter(text: String) -> Bool {
        if text == latestTextSearch {
            switch filter {
            case .music:
                return !hasLoadedMusic
            case .video:
                return !hasLoadedMv
            case .offline:
                return !hasLoadImport
            }
        } else {
            hasLoadedMusic = false
            hasLoadedMv = false
            hasLoadImport = false
            return false
        }
    }
    
    private func reloadFirst(text: String) {
        if text != latestTextSearch {
            hasLoadedMusic = false
            hasLoadedMv = false
            hasLoadImport = false
            tokenMV = ""
            tokenMusic = ""
        }
    }
    
    func searchQuery(with query: String, with newFilter: Bool = false) -> SearchStatus {
        reloadFirst(text: query)
        self.latestTextSearch = query

        switch filter {
        case .music:
            if hasLoadedMusic {return .noSearch}
                YTMManager.shared.search(query: query, filter: .music) { [weak self] ytModels, token in
                    DispatchQueue.main.async {
                        guard let ytModels = ytModels else {
                            self?.resultMusic = []
                            self?.bindingSearching?()
                            return
                        }

                        let musics = ConvertService.shared.convertArrYTSearchToArrMSModel(ytSearchs: ytModels)
                        self?.resultMusic = musics
                        self?.tokenMusic = token
                        self?.bindingSearching?()
                        self?.hasLoadedMusic = true
                    }
                }

            
        case .video:
            if hasLoadedMv {return .noSearch}

                YTMManager.shared.search(query: query, filter: .mv) { [weak self] ytModels, token in
                    DispatchQueue.main.async {
                        guard let ytModels = ytModels else {
                            self?.resultMv = []
                            self?.bindingSearching?()
                            return
                        }

                        let musics = ConvertService.shared.convertArrYTSearchToArrMSModel(ytSearchs: ytModels)
                        self?.resultMv = musics
                        self?.tokenMV = token

                        self?.bindingSearching?()
                        self?.hasLoadedMv = true
                    }
                }
            
        case .offline:
            if hasLoadImport {return .noSearch}
            
            self.loadImportFolder()
            self.resultImport = []
            self.importMusics.forEach { music in
                let nameMusic = music.name.lowercased().folding(options: .diacriticInsensitive, locale: nil)
                if nameMusic.contains(query)  {
                    resultImport.append(music)
                }
            }
            self.hasLoadImport = true
            self.bindingSearching?()
        }
        
        return .willSearching
    }
    
    func loadMore() {
		guard let token = (self.filter == .music) ? self.tokenMusic : self.tokenMV else {return}

        var ytFilter: YTSearchFilter
        switch self.filter {
            case .music: ytFilter = .music
            case .video: ytFilter = .mv
            case .offline: ytFilter = .music
        }

        YTMManager.shared.searchContinuation(filter: ytFilter, token: token) {
            [weak self] ytModels, token in

            guard let ytModels = ytModels else {return}
            let musics = ConvertService.shared.convertArrYTSearchToArrMSModel(ytSearchs: ytModels)

            switch self?.filter {
                case .music:
                    self?.resultMusic.append(contentsOf: musics)
                    self?.tokenMusic = token
                case .video:
                    self?.resultMv.append(contentsOf: musics)
                    self?.tokenMV = token
                default:
                    self?.bindingLoadmore?()
                    return
            }
            self?.bindingLoadmore?()
        }
        
    }
        
    func saveFavourite(music: MusicModel) -> Bool {
        return RealmService.shared.saveToFavourite(music: music, shoudSave: fromYoutube)
    }
    
    func loadImportFolder() {
        guard let importFolder = RealmService.shared.importPlaylist() else {return}
        
        self.importMusics = importFolder.musics.toArray(ofType: MusicModel.self)
    }
    
}


extension SearchViewModel {
    func loadData() {
        self.historyPlaylist = RealmService.shared.historyPlaylist()
    }
    
    var numberTopSearchCell: Int {
        return historyPlaylist?.musics.count ?? 0
    }
    
    func cellTopHistory(at indexPath: IndexPath) -> MusicModel {
        return historyPlaylist?.musics[indexPath.row] ?? MusicModel()
    }
    
    func saveTopSearch(indexPath: IndexPath) {
        guard let historyPlaylist = historyPlaylist else {return}
        let searchedMusic = musicForCell(at: indexPath)

        if historyPlaylist.musics.first(where: { music in
            if self.fromYoutube {
                return music.videoID == searchedMusic.videoID
            } else {
                return music.id == searchedMusic.id
            }
            
        }) != nil {
            return
        }
        
        let isExisted = RealmService.shared.isExistedMusic(music: searchedMusic)
        if !isExisted {
            RealmService.shared.saveObject(searchedMusic)
        }
        
        if numberTopSearchCell < 10 {
            try? realm?.write({
                historyPlaylist.musics.insert(searchedMusic, at: 0)
            })
            return
        }
        
        try? realm?.write({
            historyPlaylist.musics.remove(at: historyPlaylist.musics.count - 1)
            historyPlaylist.musics.insert(searchedMusic, at: 0)
        })
        
    }
    
    func didSelectMusicTopSearch(at indexPath: IndexPath) {
        let searchedMusic = musicForCell(at: indexPath)
        bindingDidSelectTopHistory?(searchedMusic)
    }
    
    func nameCellHistory(at indexPath: IndexPath) -> String {
        return cellTopHistory(at: indexPath).name
    }
}
