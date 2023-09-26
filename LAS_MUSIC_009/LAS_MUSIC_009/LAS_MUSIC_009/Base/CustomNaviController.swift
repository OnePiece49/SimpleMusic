//
//  CustomNaviController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 14/08/2023.
//

import UIKit

class CustomNavigationController: UINavigationController {
    // Return the visible child view controller
    // which determines the status bar style.
    override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
    
    
}

