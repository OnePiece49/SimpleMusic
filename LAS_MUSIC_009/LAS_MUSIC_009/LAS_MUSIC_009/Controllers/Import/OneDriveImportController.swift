//
//  OneDriveImportController.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 15/08/2023.
//

import UIKit
import MSAL

class OneDriveImportController: ImportBaseController {

	private let realm = RealmService.shared.realmObj()
	private let importPlaylist = RealmService.shared.importPlaylist()
	private var files: [OneDriveModel] = []
	private var accessToken: String?

	// MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		setupTBView()
		signinButton.addTarget(self, action: #selector(singinBtnTapped), for: .touchUpInside)
		checkCurrentAccount()
    }

	private func setupTBView() {
		downloadTB.delegate = self
		downloadTB.dataSource = self
		downloadTB.register(OneDriveTBCell.self, forCellReuseIdentifier: OneDriveTBCell.cellId)
	}
}

// MARK: - Method
extension OneDriveImportController {

	private func checkCurrentAccount() {
		if let account = OneDriveManager.shared.getSignedInAccount() {
			loadingIndicator.startAnimating()
			getTokenSilently()
			updateCenterNav(with: account.username ?? "")
		}
	}

	private func getTokenSilently() {
		OneDriveManager.shared.getTokenSilently { [weak self] accessToken in
			if let token = accessToken {
				self?.signinButton.setTitle("SIGN OUT", for: .normal)
				self?.accessToken = token
				self?.getAllFiles()
			}
		}
	}

	private func getTokenInteractively() {
		OneDriveManager.shared.getTokenInteractively(parentController: self) { [weak self] accessToken in
			if let token = accessToken {
				let account = OneDriveManager.shared.getSignedInAccount()
				self?.updateCenterNav(with: account?.username ?? "")
				self?.signinButton.setTitle("SIGN OUT", for: .normal)
				self?.accessToken = token
				self?.getAllFiles()
			}
		}
	}

	private func getAllFiles() {
		guard let accessToken = accessToken else { return }

		OneDriveManager.shared.getAllFiles(token: accessToken) { [weak self] models in
			self?.loadingIndicator.stopAnimating()
			guard let models = models else { return }
			self?.files = models
			self?.downloadTB.reloadData()
		}
	}

	@objc private func singinBtnTapped() {
		if let _ = OneDriveManager.shared.getSignedInAccount() {
			signOutAccount()
		} else {
			getTokenInteractively()
		}
	}

	private func signOutAccount() {
		let singedOut = OneDriveManager.shared.signOutAccount()

		if singedOut {
			updateCenterNav(with: "")
			signinButton.setTitle("SIGN IN", for: .normal)
			files.removeAll()
			downloadTB.reloadData()
		}
	}

	private func downloadFile(_ file: OneDriveModel) {
		let validName = getValidFileName(from: file.name)
		guard let destinationURL = URL.importFolder()?.appendingPathComponent(validName) else { return }

		if FileManager.default.fileExists(atPath: destinationURL.path) {
			view.displayToast("Failed to import: File already existed")
			return
		}

		guard let urlString = file.downloadURL, let downloadURL = URL(string: urlString) else {
			view.displayToast("Can not import file")
			return
		}

		let loadingView = LoadingView(message: "Importing...")
		loadingView.show()

		OneDriveManager.shared.downloadFile(downloadURL: downloadURL, outputURL: destinationURL) { [weak self] outputURL in
			guard let outputURL = outputURL else {
				self?.view.displayToast("Failed to import file")
				return
			}
			self?.saveMusicToRealm(file: file, url: outputURL)
			loadingView.dismiss()
		}
	}

	private func saveMusicToRealm(file: OneDriveModel, url: URL) {
		var type: MusicType = .audio
		var duration: Double = 0
		var artist: String?
		var thumbnail: String?

		if let video = file.video {
			type = .video
			duration = video.duration / 1000
		} else if let audio = file.audio {
			type = .audio
			duration = audio.duration / 1000
			artist = audio.artist
		}

		if let thumbnailString = file.thumbnails?.first?.small.url {
			thumbnail = thumbnailString
		}
		let name = file.name
		let relativePath = url.path.replacingOccurrences(of: "\(URL.document().path)/", with: "")

		let musicId = RealmService.shared.saveImportedMusic(name: name, duration: duration, artist: artist,
															type: type, thumbnail: thumbnail, relativePath: relativePath)

		if let _ = musicId {
			view.displayToast("Import file successful")
		} else {
			try? FileManager.default.removeItem(at: url)
			view.displayToast("Failed to import file")
		}
	}
}

// MARK: - UITableViewDataSource
extension OneDriveImportController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return files.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: OneDriveTBCell.cellId,
												 for: indexPath) as! OneDriveTBCell
		cell.model = files[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let file = files[indexPath.row]
		self.downloadFile(file)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return OneDriveTBCell.heightCell
	}
}
