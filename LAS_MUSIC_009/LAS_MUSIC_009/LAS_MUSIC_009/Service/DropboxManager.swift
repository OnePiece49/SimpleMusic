//
//  DropboxManager.swift
//  Learning-Dropbox
//
//  Created by Đức Anh Trần on 10/08/2023.
//

import Foundation
import SwiftyDropbox

class DropboxManager {

	static let shared = DropboxManager()

	private var client: DropboxClient? {
		return DropboxClientsManager.authorizedClient
	}

	private let serialQueue = DispatchQueue(label: "dropbox-manager-queue")

	// MARK: - Public
	func checkSignInUser() -> Bool {
		return client != nil
	}

	func unlinkUser() {
		DropboxClientsManager.unlinkClients()
	}

	func getUserEmail(completion: @escaping (_ email: String?) -> Void) {
		guard let client = client else {
			DispatchQueue.main.async { completion(nil) }
			return
		}

		let _ = client.users.getCurrentAccount()
			.response(queue: serialQueue) { response, error in
				guard let account = response else {
					DispatchQueue.main.async { completion(nil) }
					return
				}
				DispatchQueue.main.async { completion(account.email) }
		}
	}

	func getAllFiles(completion: @escaping (_ filesMetadata: [Files.FileMetadata], _ cursor: String?) -> Void) {
		guard let client = client else {
			DispatchQueue.main.async { completion([], nil) }
			return
		}

		var filesMetadata: [Files.FileMetadata] = []
		
		let _ = client.files.listFolder(path: "", recursive: true)
			.response(queue: serialQueue) { [weak self] response, error in
				guard let self = self else { return }

				guard let result = response, error == nil else {
					DispatchQueue.main.async { completion([], nil) }
					return
				}

				let cursor: String? = result.hasMore ? result.cursor : nil

				for entry in result.entries {
					if let file = entry as? Files.FileMetadata { // only accpect file, not folder
						if let path = file.pathDisplay {
							if self.filterFile(filename: path) {
								filesMetadata.append(file)
							}
						}
					}
				}

				DispatchQueue.main.async { completion(filesMetadata, cursor) }
			}
	}

	func getMoreFiles(cursor: String,
					  completion: @escaping (_ filesMetadata: [Files.FileMetadata], _ cursor: String?) -> Void) {

		guard let client = client else {
			DispatchQueue.main.async { completion([], nil) }
			return
		}

		var filesMetadata: [Files.FileMetadata] = []

		let _ = client.files.listFolderContinue(cursor: cursor)
			.response(queue: serialQueue) { [weak self] response, error in
				guard let self = self else { return }

				guard let result = response, error == nil else {
					DispatchQueue.main.async { completion([], nil) }
					return
				}

				let cursor: String? = result.hasMore ? result.cursor : nil

				for entry in result.entries {
					if let file = entry as? Files.FileMetadata { // only accpect file, not folder
						if let path = file.pathDisplay {
							if self.filterFile(filename: path) {
								filesMetadata.append(file)
							}
						}
					}
				}

				DispatchQueue.main.async { completion(filesMetadata, cursor) }
			}
	}

	func downloadFile(fileMetadata: Files.FileMetadata,
					  outputURL: URL,
					  completion: @escaping (_ outputURL: URL?, _ mediaInfo: Files.MediaInfo?) -> Void) {

		guard let client = client, let path = fileMetadata.pathDisplay else {
			DispatchQueue.main.async { completion(nil, nil) }
			return
		}

		let destination: (URL, HTTPURLResponse) -> URL = { tempURL, response in
			return outputURL
		}

		let _ = client.files.download(path: path, overwrite: true, destination: destination)
			.response(queue: serialQueue) { response, error in
				if let (file, url) = response {
					DispatchQueue.main.async { completion(url, file.mediaInfo) }

				} else if let _ = error {
					DispatchQueue.main.async { completion(nil, nil) }
				}
			}
	}

	func getFileThumbnail(fileMetadata: Files.FileMetadata,
						  outputURL: URL,
						  completion: @escaping (_ outputURL: URL?) -> Void) {

		guard let client = client, let path = fileMetadata.pathDisplay else {
			DispatchQueue.main.async { completion(nil) }
			return
		}

		let destination: (URL, HTTPURLResponse) -> URL = { tempURL, response in
			return outputURL
		}

		client.files.getThumbnail(path: path, size: .w256h256, mode: .strict, destination: destination)
			.response { response, error in
				if let (_, url) = response {
					DispatchQueue.main.async { completion(url) }

				} else if let _ = error {
					DispatchQueue.main.async { completion(nil) }
				}
			}
	}

	// MARK: - Private
	private func filterFile(filename: String) -> Bool {
		let acceptableExtension: [String] = ["mp3", "mp4"]

		if let ext = filename.lowercased().split(separator: ".").last {
			if acceptableExtension.contains(String(ext)) {
				return true
			}
		}
		return false
	}

}
