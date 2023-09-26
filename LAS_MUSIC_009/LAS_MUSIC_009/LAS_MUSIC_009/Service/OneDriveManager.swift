//
//  OneDriveManager.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 15/08/2023.
//

import UIKit
import MSAL

class OneDriveManager {

	static let shared = OneDriveManager()

	private var clientApplication: MSALPublicClientApplication?

	private let kGraphScopes: [String] = ["files.read", "user.read"]

	// MARK: - Init
	init() {
		guard let authorityURL = URL(string: AppConstant.OneDrive.authority) else { return }

		do {
			let authority = try MSALAADAuthority(url: authorityURL)
			let msalConfiguration = MSALPublicClientApplicationConfig(clientId: AppConstant.OneDrive.client_id,
																	  redirectUri: nil,
																	  authority: authority)
			self.clientApplication = try MSALPublicClientApplication(configuration: msalConfiguration)

		} catch {
			self.clientApplication = nil
			print("\(#function) - error: \(error)")
		}
	}

	// MARK: - Public method
	func getSignedInAccount() -> MSALAccount? {
		if let account = try? clientApplication?.allAccounts().first {
			return account
		}
		return nil
	}

	func signOutAccount() -> Bool {
		do {
			if let accounts = try? clientApplication?.allAccounts() {
				for acc in accounts {
					try clientApplication?.remove(acc)
				}
				return true
			}
			return false
		} catch {
			return false
		}
	}

	func getTokenInteractively(parentController: UIViewController,
							   completion: @escaping (_ token: String?) -> Void) {

		guard let clientApplication = clientApplication else { return }

		let webParameters = MSALWebviewParameters(authPresentationViewController: parentController)
		let interactiveParams = MSALInteractiveTokenParameters(scopes: kGraphScopes, webviewParameters: webParameters)
		interactiveParams.promptType = MSALPromptType.selectAccount

		clientApplication.acquireToken(with: interactiveParams) { result, error in
			guard let result = result, error == nil else {
				DispatchQueue.main.async { completion(nil) }
				return
			}
			DispatchQueue.main.async { completion(result.accessToken) }
		}
	}

	func getTokenSilently(completion: @escaping (_ accessToken: String?) -> Void) {
		guard let clientApplication = clientApplication,
			  let account = try? clientApplication.allAccounts().first else {
			completion(nil)
			return
		}

		let silentParams = MSALSilentTokenParameters(scopes: kGraphScopes, account: account)

		clientApplication.acquireTokenSilent(with: silentParams) { result, error in
			guard let result = result, error == nil else {
				DispatchQueue.main.async { completion(nil) }
				return
			}
			DispatchQueue.main.async { completion(result.accessToken) }
		}
	}

	func getAllFiles(token: String,
					 completion: @escaping (_ models: [OneDriveModel]?) -> Void) {

		let path = "/v1.0/me/drive/root/children"
		let queryItems = [
			URLQueryItem(name: "filter", value: "file ne null and (file/mimeType eq 'audio/mpeg' or file/mimeType eq 'video/mp4')"),
			URLQueryItem(name: "expand", value: "thumbnails")
		]

		guard let request = createURLRequest(token: token, path: path, queryItems: queryItems) else {
			DispatchQueue.main.async { completion(nil) }
			return
		}

		URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				DispatchQueue.main.async { completion(nil) }
				return
			}

			do {
				let model = try JSONDecoder().decode(OneDriveResponse.self, from: data)
				DispatchQueue.main.async { completion(model.value) }
			} catch {
				DispatchQueue.main.async { completion(nil) }
			}
		}.resume()
	}

	func downloadFile(downloadURL: URL,
					  outputURL: URL,
					  completion: @escaping (_ outputURL: URL?) -> Void) {
		
		URLSession.shared.downloadTask(with: downloadURL) { tempURL, response, error in
			guard let tempURL = tempURL, error == nil else {
				DispatchQueue.main.async { completion(nil) }
				return
			}

			do {
				try FileManager.default.copyItem(at: tempURL, to: outputURL)
				DispatchQueue.main.async { completion(outputURL) }
			} catch {
				DispatchQueue.main.async { completion(nil) }
			}
		}.resume()
	}

	// MARK: - Private method
	private func createURLRequest(token: String,
								  path: String,
								  queryItems: [URLQueryItem]? = nil) -> URLRequest? {

		var components = URLComponents()
		components.scheme = "https"
		components.host = "graph.microsoft.com"
		components.path = path
		components.queryItems = queryItems

		if let url = components.url {
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
			return request
		}
		return nil
	}
}
