//
//  GoogleDriveController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 14/08/2023.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import AVFoundation

class GoogleDriveController: ImportBaseController {
    
    //MARK: - Properties
    let realm = RealmService.shared.realmObj()
    let service = GTLRDriveService()
    var files: [GTLRDrive_File] = []
    
    var token: String? = nil
    var shouldLoadMore = true
    
    //MARK: - UIComponent
    let loadingView = LoadingView(message: "Importing...")
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
		signinButton.addTarget(self, action: #selector(handleSignInButtonTapped), for: .touchUpInside)
        configureProperties()
        checkUser()
    }

    
    override func configureUI() {
        super.configureUI()
        
        view.addSubview(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            loadingView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            loadingView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        loadingIndicator.stopAnimating()
        loadingView.alpha = 0
    }
    
}

//MARK: - Method
extension GoogleDriveController {
    
    //MARK: - Helpers
    private func configureProperties() {
        downloadTB.delegate = self
        downloadTB.dataSource = self
        downloadTB.register(GGDriveTBCell.self, forCellReuseIdentifier: GGDriveTBCell.cellId)
        downloadTB.rowHeight = UITableView.automaticDimension
		service.apiKey = AppConstant.GoogleDrive.api_key
    }
    
    private func checkUser() {
        if GIDSignIn.sharedInstance.currentUser != nil {
            self.updateSignIn(user: GIDSignIn.sharedInstance.currentUser!)
        } 
    }
    
    private func setupGoogleSignIn() {
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self, hint: nil, additionalScopes: [kGTLRAuthScopeDrive]) { signInResult, error in
            guard let signInResult = signInResult else { return }

            let user = signInResult.user
            self.updateSignIn(user: user)
        }
    }
    
    //MARK: - Selectors
    @objc func handleSignInButtonTapped() {
        if GIDSignIn.sharedInstance.currentUser == nil {
            setupGoogleSignIn()
        } else {
            GIDSignIn.sharedInstance.signOut()
            updateSignOut()
        }
    }
    
}

// MARK: - Method
extension GoogleDriveController {
    
    private func updateSignIn(user: GIDGoogleUser) {
        let emailAddress = user.profile?.email
        self.updateCenterNav(with: emailAddress ?? "")
        self.service.authorizer = user.fetcherAuthorizer
        self.signinButton.setTitle("SIGN OUT", for: .normal)
        
        self.listFiles()
    }
    
    private func updateSignOut() {
        self.updateCenterNav(with: "")
        self.service.authorizer = nil
        self.token = nil
        self.signinButton.setTitle("SIGN IN", for: .normal)
        self.files = []
        self.downloadTB.reloadData()
        self.downloadTB.isScrollEnabled = false
    }
    
    private func listFiles(firstLoad: Bool = true) {
        loadingIndicator.startAnimating()

		let root = AppConstant.GoogleDrive.root_type_video_audio
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = root
        query.pageToken = self.token
		query.fields = AppConstant.GoogleDrive.field_requets
        
        service.executeQuery(query)  { [weak self] ticker, result, error in
            self?.loadingIndicator.stopAnimating()
            if let _ = error {
                return
            }
            
            guard let data = result as? GTLRDrive_FileList, let files = data.files else {return}
            if !firstLoad && self?.token == nil {
                return
            }
            
            let filesCanDownload = files.filter { file in
                return file.viewersCanCopyContent == 1
            }
            self?.token = data.nextPageToken
            
            self?.files.append(contentsOf: filesCanDownload)
            self?.downloadTB.reloadData()
            self?.downloadTB.layoutIfNeeded()
            self?.downloadTB.isScrollEnabled = true
            self?.shouldLoadMore = true
        }
    }
    
    private func downloadData(file: GTLRDrive_File?) {
        let name = file?.name ?? ""
        
        guard let url = URL.importFolder()?.appendingPathComponent(name.replacingOccurrences(of: "[\\s\\n]+", with: "", options: .regularExpression, range: nil)) else {return}
        if FileManager.default.fileExists(atPath: url.path) {
            self.view.displayToast("File is existed", duration: 2.0, position: .center)
            return
        }
        
        guard let id = file?.identifier, let file = file else {return}
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: id)
        self.loadingView.show()
        
        service.executeQuery(query) { ticker, result, error in
            self.loadingView.dismiss()
            guard let result = result as? GTLRDataObject else {
                self.loadingView.dismiss()
                self.view.displayToast("Import file  \(name) failed with \(error?.localizedDescription ?? "")", duration: 2.0, position: .center)
                return
            }
            
            self.saveData(objectFile: result, file: file)
        }
    }
    
    private func saveData(objectFile: GTLRDataObject, file: GTLRDrive_File) {
        let name = file.name ?? ""

		guard let url = URL.importFolder()?.appendingPathComponent(getValidFileName(from: name)) else { return }
        self.loadingView.dismiss()

        do {
            try objectFile.data.write(to: url)

			var type: MusicType
			var thumbnail: String?

			if file.mimeType == "video/mp4" || file.mimeType == "video/mov" {
				type = .video
			} else {
				type = .audio
			}

			if file.hasThumbnail == true {
				thumbnail = file.thumbnailLink
			}

			let asset = AVAsset(url: url)
			let duration = CMTimeGetSeconds(asset.duration)
			let relativePath = url.path.replacingOccurrences(of: "\(URL.document().path)/", with: "")

			let musicId = RealmService.shared.saveImportedMusic(name: name, duration: duration, artist: nil,
																type: type, thumbnail: thumbnail, relativePath: relativePath)

			if let _ = musicId {
				view.displayToast("Import file \(name) successfully")
			} else {
				view.displayToast("Import file \(name) failed")
			}


//            let music = MusicModel()
//            if file.mimeType == "video/mp4" {
//                music.type = .video
//            } else {
//                music.type = .audio
//            }
//            music.name = name
//            music.durationDouble = asset.duration.seconds
//            music.sourceType = .offline
//            music.relativePath = url.path.replacingOccurrences(of: "\(URL.document().path)/", with: "")
//            music.creationDate = Date().timeIntervalSince1970
//            if file.hasThumbnail == true {
//                music.thumbnailURL = file.thumbnailLink
//            }
//
//            let success = RealmService.shared.saveObject(music)
//            if success {
//                self.view.displayToast("Import file \(name) successfully", duration: 2.0, position: .center)
//            } else {
//                self.view.displayToast("Import file \(name) failed", duration: 2.0, position: .center)
//            }
//
//            try realm?.write({
//                RealmService.shared.importPlaylist()?.musics.append(music)
//            })
            
            
        } catch {
            self.view.displayToast("Import file \(name) failed with \(error.localizedDescription)")
        }
        
    }
    
}


extension GoogleDriveController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GGDriveTBCell.cellId,
                                                 for: indexPath) as! GGDriveTBCell
        cell.file = files[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! GGDriveTBCell
        
        self.downloadData(file: cell.file)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != downloadTB {
            return
        }
        
        let y = scrollView.contentOffset.y
        if y > downloadTB.contentSize.height - view.frame.height && shouldLoadMore {
            shouldLoadMore = false
            self.listFiles(firstLoad: false)
        }
    }
    
}

