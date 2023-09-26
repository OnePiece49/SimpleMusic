//
//  SceneDelegate.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 13/08/2023.
//

import UIKit
import GoogleSignIn
import SwiftyDropbox
import MSAL

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scence = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scence)
        self.window = window
		let configureDrive = GIDConfiguration(clientID: AppConstant.GoogleDrive.client_id)
        GIDSignIn.sharedInstance.configuration = configureDrive
        RealmService.shared.configuration()
        
        window.rootViewController = CustomNavigationController(rootViewController: TabBarController())
        window.makeKeyAndVisible()
    }
 
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let context = URLContexts.first else { return }

		if context.url.scheme == AppConstant.kDropboxUrlScheme {
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
			DropboxClientsManager.handleRedirectURL(context.url, completion: oauthCompletion)

		} else if context.url.scheme == AppConstant.kOnedriveUrlScheme {
			let sourceApp = context.options.sourceApplication
			MSALPublicClientApplication.handleMSALResponse(context.url, sourceApplication: sourceApp)

		}
	}

}

