//
//  AppDelegate.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 13/08/2023.
//

import UIKit
import AVFoundation
import RealmSwift
import GoogleSignIn
import SwiftyDropbox
import MSAL

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        let root = CustomNavigationController(rootViewController: TabBarController())
        root.setNavigationBarHidden(true, animated: false)

        RealmService.shared.configuration()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: .default)
        } catch let error as NSError {
            print("DEBUG: Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
        }

		// setup googledrive
		let configureDrive = GIDConfiguration(clientID: AppConstant.GoogleDrive.client_id)
		GIDSignIn.sharedInstance.configuration = configureDrive

		// setup dropbox
		DropboxClientsManager.setupWithAppKey(AppConstant.Dropbox.app_key)
        print("DEBUG: \(URL.document())")
        return true
    }

	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		if url.scheme == AppConstant.kDropboxUrlScheme {
			let oauthCompletion: DropboxOAuthCompletion = {
				if let authResult = $0 {
					switch authResult {
						case .success:
							print("Success! User is logged into DropboxClientsManager.")
						case .cancel:
							print("Authorization flow was manually canceled by user!")
						case .error(_, let description):
							print("Error: \(String(describing: description))")
					}
				}
			}

			let canHandleUrl = DropboxClientsManager.handleRedirectURL(url, completion: oauthCompletion)
			return canHandleUrl

		} else if url.scheme == AppConstant.kOnedriveUrlScheme {
			return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)

		}

		return true
	}

}

