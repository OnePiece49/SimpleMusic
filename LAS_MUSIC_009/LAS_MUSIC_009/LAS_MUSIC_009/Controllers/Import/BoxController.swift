//
//  BoxController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 15/08/2023.
//

import UIKit
import BoxSDK
import AuthenticationServices
import AuthenticationServices
import AVFoundation

class BoxController: ImportBaseController {
    
    //MARK: - Properties
    let realm = RealmService.shared.realmObj()
    
    let sdk = BoxSDK(clientId: AppConstant.Box.client_id,
                     clientSecret: AppConstant.Box.client_secret)
    var client: BoxClient?
    var files: [File] = []
    
    //MARK: - UIComponent
    let loadingView = LoadingView(message: "Importing...")
    
    //MARK: - View Lifecycle
    deinit {
        print("DEBUG: ImportBaseController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signinButton.addTarget(self, action: #selector(handleSignInButtonTapped), for: .touchUpInside)
        configureProperties()
        boxLogin()
    }
    
    override func configureUI() {
        super.configureUI()
        
        view.addSubview(loadingIndicator)
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
extension BoxController {
    
    //MARK: - Helpers
    private func configureProperties() {
        downloadTB.delegate = self
        downloadTB.dataSource = self
        downloadTB.register(BoxTBCell.self, forCellReuseIdentifier: BoxTBCell.cellId)
        downloadTB.rowHeight = UITableView.automaticDimension
    }

    private func loginCompletion(result: Result<BoxClient, BoxSDKError>) {
        switch result {
        case let .success(client):
            self.client = client
            
            self.client?.users.getCurrent(fields: ["name", "login"]) { (result: Result<User, BoxSDKError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        
                        self.updateSignIn(user: user)
                    case .failure(let error):
                        self.loadingIndicator.stopAnimating()
                        self.view.displayToast("Login failed \(error.localizedDescription)")
                    }
                }
            }
            
        case let .failure(error):
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.view.displayToast("Login failed \(error.localizedDescription)")
            }
        }
    }
    
    private func boxLogin() {
        self.loadingIndicator.startAnimating()
        if #available(iOS 13.0, *) {
            sdk.getOAuth2Client(tokenStore: KeychainTokenStore(), context: self) { [weak self] result in
                self?.loginCompletion(result: result)
            }
            
        } else {
            sdk.getOAuth2Client(tokenStore: KeychainTokenStore()) { [weak self] result in
                self?.loginCompletion(result: result)
            }
        }
    }
    
    //MARK: - Selectors
    @objc func handleSignInButtonTapped() {
        if client == nil {
            boxLogin()
        } else {
            client?.destroy() { result in
                DispatchQueue.main.async {
                    guard case .success = result else {
                        self.view.displayToast("Logout failed")
                        return
                    }

                    self.updateSignOut()
                }
            }
        }
    }
    
}

// MARK: - Method
extension BoxController {
    
    private func updateSignIn(user: User) {
        self.signinButton.setTitle("SIGN OUT", for: .normal)
        self.updateCenterNav(with: user.login ?? "")
        self.downloadTB.isScrollEnabled = true
        self.listFiles()
    }
    
    private func updateSignOut() {
        self.updateCenterNav(with: "")
        self.signinButton.setTitle("SIGN IN", for: .normal)
        self.downloadTB.reloadData()
        self.files = []
        self.client = nil
        self.downloadTB.isScrollEnabled = false
    }
    
    private func checkIfLogin() {
        
    }
    
    private func listFiles() {
        client?.search.query(query: "mp3 OR mp4 OR mov", fileExtensions: ["mp3, mp4, mov"]).next { result in
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                switch result {
                case .success(let page):
                    for item in page.entries {
                        switch item {
                        case let .file(file):
                            self.files.append(file)
                        default:
                            return
                        }
                    }
                    
                    self.downloadTB.reloadData()
                case .failure(let error) :
                    self.view.displayToast("Load File Failed - \(error.message)")
                }
            }

        }
    }
    
    private func downloadData(file: File?) {
        let name = file?.name ?? ""
        
        guard let url = URL.importFolder()?.appendingPathComponent(name.replacingOccurrences(of: "[\\s\\n]+", with: "", options: .regularExpression, range: nil)), let file = file else {return}
        
        if FileManager.default.fileExists(atPath: url.path) {
            self.view.displayToast("File is existed", duration: 2.0, position: .center)
            return
        }
        self.loadingView.show()
        self.client?.files.download(fileId: file.id, destinationURL: url) { (result: Result<Void, BoxSDKError>) in
			DispatchQueue.main.async {
				self.loadingView.dismiss()
				switch result {
					case .success:
						self.saveToRealm(file: file)
					case .failure(let failure):
						self.view.displayToast("Download file failed - \(failure.message)")
				}
			}
        }
    }
    
    private func saveToRealm(file: File) {
        let name = file.name ?? ""
        guard let url = URL.importFolder()?.appendingPathComponent(getValidFileName(from: name)) else {return}

		var type: MusicType
        if url.pathExtension.lowercased() == "mp4" || url.pathExtension.lowercased() == "mov" {
			type = .video
		} else {
			type = .audio
		}

		let asset = AVAsset(url: url)
		let duration = CMTimeGetSeconds(asset.duration)
		let relativePath = url.path.replacingOccurrences(of: "\(URL.document().path)/", with: "")


		let musicId = RealmService.shared.saveImportedMusic(name: name, duration: duration, artist: nil,
															type: type, thumbnail: nil, relativePath: relativePath)

		if let musicId = musicId {
			if type == .video {
				self.downloadThumbnail(file: file) { thumbnailUrl in
					RealmService.shared.updateMusicThumbnail(thumbnailUrl, musicId: musicId)
				}
			}
			view.displayToast("Import file \(name) successfully")

		} else {
			view.displayToast("Import file \(name) field")
		}

//        let asset = AVAsset(url: url)
//        let music = MusicModel()
//        music.name = name
//        music.durationDouble = asset.duration.seconds
//        music.sourceType = .offline
//        music.relativePath = url.path.replacingOccurrences(of: "\(URL.document().path)/", with: "")
//        music.creationDate = Date().timeIntervalSince1970
//        if url.pathExtension == "mp4" || url.pathExtension == "mov" {
//            music.type = .video
//        } else {
//            music.type = .audio
//        }
//
//        if music.type == .audio {
//            DispatchQueue.main.async {
//                self.loadingView.dismiss()
//                do {
//                    try self.realm?.write({
//                        RealmService.shared.importPlaylist()?.musics.append(music)
//                        self.view.displayToast("Import file \(name) successfully")
//                        self.realm?.add(music)
//                    })
//
//                    self.view.displayToast("Import file \(name) successfully")
//                } catch {
//                    self.view.displayToast("Import file \(name) field")
//                }
//            }
//
//            return
//        }
//
//        self.client?.files.getThumbnail(forFile: file.id, extension: .png, minWidth: 80, maxWidth: 400, completion: { result in
//            DispatchQueue.main.async {
//                self.loadingView.dismiss()
//                do {
//                    guard case let .success(thumbnailData) = result else {
//                        try self.realm?.write({
//                            RealmService.shared.importPlaylist()?.musics.append(music)
//                            self.view.displayToast("Import file \(name) successfully")
//                            self.realm?.add(music)
//                        })
//                        return
//                    }
//
//                    try thumbnailData.write(to: thumbnailUrl)
//
//                    music.thumbnailURL = thumbnailUrl.absoluteString
//                    try self.realm?.write({
//                        RealmService.shared.importPlaylist()?.musics.append(music)
//                        self.realm?.add(music)
//                    })
//                    self.view.displayToast("Import file \(name) successfully")
//                } catch {
//                    self.view.displayToast("Import file \(name) field")
//                }
//            }
//
//        })
    }

	func downloadThumbnail(file: File, completion: @escaping (_ thumbnailUrl: String?) -> Void) {
		guard let thumbnailUrl = URL.thumbnailFolder()?.appendingPathComponent(file.name ?? "").appendingPathExtension("png") else {return}

		self.client?.files.getThumbnail(forFile: file.id, extension: .png, minWidth: 80, maxWidth: 400) { result in
			switch result {
				case .success(let thumbnailData):
					do {
						try thumbnailData.write(to: thumbnailUrl)
						DispatchQueue.main.async { completion(thumbnailUrl.absoluteString) }
					} catch {
						DispatchQueue.main.async { completion(nil) }
					}
				case .failure(_):
					DispatchQueue.main.async { completion(nil) }
			}
		}
//			DispatchQueue.main.async {
//				self.loadingView.dismiss()
//				do {
//					guard case let .success(thumbnailData) = result else {
//						try self.realm?.write({
//							RealmService.shared.importPlaylist()?.musics.append(music)
//							self.view.displayToast("Import file \(name) successfully")
//							self.realm?.add(music)
//						})
//						return
//					}
//
//					try thumbnailData.write(to: thumbnailUrl)
//
//					music.thumbnailURL = thumbnailUrl.absoluteString
//					try self.realm?.write({
//						RealmService.shared.importPlaylist()?.musics.append(music)
//						self.realm?.add(music)
//					})
//					self.view.displayToast("Import file \(name) successfully")
//				} catch {
//					self.view.displayToast("Import file \(name) field")
//				}
//			}

	}
}

// MARK: - delegate ASWebAuthenticationPresentationContextProviding
extension BoxController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        self.view.window ?? ASPresentationAnchor()
    }
    
}

// MARK: - delegate UITableViewDelegate, UITableViewDataSource
extension BoxController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BoxTBCell.cellId,
                                                 for: indexPath) as! BoxTBCell
        cell.file = files[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! BoxTBCell
        self.downloadData(file: cell.file)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    
}

