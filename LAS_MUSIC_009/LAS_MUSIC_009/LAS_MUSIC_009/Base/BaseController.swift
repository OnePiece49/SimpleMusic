//
//  BaseController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 13/08/2023.
//

import UIKit
import RealmSwift

class BaseController: UIViewController {
    
    //MARK: - Properties
    var isIphone: Bool {
        return UIDevice.current.is_iPhone
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    var heightDevice: CGFloat {
        return view.frame.height
    }
    
    var widthDevice: CGFloat {
        return view.frame.width
    }
    
    //MARK: - UIComponent
    
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .primaryBackgroundColor
        self.navigationController?.navigationBar.isHidden = true
    }
    
}

// MARK: - Method
extension BaseController {
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
	func playMusic(playlist: PlaylistModel, currentMusic: MusicModel, replayMode: ReplayMode = .none) {
        guard let tabBarVC = self.tabBarController as? TabBarController else {
            guard let tabBarVC = self.navigationController?.viewControllers.first as? TabBarController else {return}
			tabBarVC.playerVC.viewModel.newPlaylist(playlist: playlist, currentMusic: currentMusic, replayMode: replayMode)
            tabBarVC.presentPlayerVCFullScreen()
            return
        }
        
		tabBarVC.playerVC.viewModel.newPlaylist(playlist: playlist, currentMusic: currentMusic, replayMode: replayMode)
        tabBarVC.presentPlayerVCFullScreen()
    }

	func getValidFileName(from name: String) -> String {
		return name.replacingOccurrences(of: "[\\s\\n]+", with: "", options: .regularExpression, range: nil)
	}

}
