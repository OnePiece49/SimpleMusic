//
//  TabBarController.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 28/07/2023.
//

import UIKit


class TabBarController: UITabBarController {
    
    // MARK: - Properties
    let playerVC = PlayerController()
    
    var frameTabBar: CGRect!
    var positionHiddentTabBar: CGFloat!
    var durationAnimation: TimeInterval = 0.2
    
    var heightTabBar: CGFloat {
        return tabBar.frame.height
    }
    
    var heightDevice: CGFloat {
        return view.frame.height
    }

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        configureUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.setupPlayer()
        }
        
        print("DEBUG: heightDevice: \(heightDevice) and heightTabBar: \(heightTabBar)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
    }

    func configureUI() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        let homeVC = templateNavigationController(
            rootViewController: HomeVC(),
            image: UIImage(named: AssetConstant.ic_home_unselect)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: AssetConstant.ic_home_select)?.withRenderingMode(.alwaysOriginal),
            title: "Home")

        let importVC = templateNavigationController(
            rootViewController: ImportController(),
            image: UIImage(named: AssetConstant.ic_import_unselect)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: AssetConstant.ic_import_select)?.withRenderingMode(.alwaysOriginal),
            title: "Import")

        let filesVC = templateNavigationController(
            rootViewController: MyFilesController(),
            image: UIImage(named: AssetConstant.ic_files_unselect)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: AssetConstant.ic_files_select)?.withRenderingMode(.alwaysOriginal),
            title: "My Files")

        let settingVC = templateNavigationController(
            rootViewController: SettingsController(),
            image: UIImage(named: AssetConstant.ic_home_unselect)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: AssetConstant.ic_home_select)?.withRenderingMode(.alwaysOriginal),
            title: "Settings")

        self.viewControllers = [homeVC, importVC, filesVC, settingVC]

		tabBar.barTintColor = .clear
        tabBar.tintColor = .secondaryYellow
        tabBar.unselectedItemTintColor = UIColor(rgb: 0x71737B)
        tabBar.backgroundColor = UIColor(rgb: 0x100F11)
    }

    //MARK: - Helpers
    private func templateNavigationController(rootViewController rootVC: UIViewController,
                                              image: UIImage?,
                                              selectedImage: UIImage?,
                                              title: String) -> UIViewController {
        rootVC.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        return rootVC
    }
    
    private func setupPlayer() {
        guard let viewPlayerVC = playerVC.view else {return}
        playerVC.delegate = self
        addChild(playerVC)
        view.addSubview(viewPlayerVC)
  
        viewPlayerVC.frame = .init(x: 0, y: heightDevice, width: view.frame.width, height: heightDevice + 73)
        playerVC.didMove(toParent: self)
        view.bringSubviewToFront(tabBar)
        self.tabBar.frame.origin.y = heightDevice
        self.positionHiddentTabBar = heightDevice
        viewPlayerVC.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleViewPlayerVCMoved)))
        viewPlayerVC.isUserInteractionEnabled = true
        self.view.layoutIfNeeded()
    }
    
    private func animationTarBar(y: CGFloat) {
        self.tabBar.frame.origin.y = self.positionHiddentTabBar - y
    }
    
    // MARK: - Selectors
    
    @objc func handleViewPlayerVCMoved(geture: UIPanGestureRecognizer) {
        
        guard let viewPlayerVC = playerVC.view else {return}
        let y = geture.translation(in: view).y
        let veclocitY = geture.velocity(in: view).y
        
        if geture.state == .changed {
            if y > 0 && y < (heightDevice - heightTabBar) {
                viewPlayerVC.frame.origin.y = -MiniPlayerView.heightView + y
                let transitionTabBar = y / (-MiniPlayerView.heightView + heightDevice - heightTabBar) * heightTabBar
                self.animationTarBar(y: transitionTabBar)
                
            } else if y > 0 && y >= (heightDevice - heightTabBar) {
                UIView.animate(withDuration: durationAnimation) {
                    
                    viewPlayerVC.frame.origin.y  = self.heightDevice - self.heightTabBar
                    self.animationTarBar(y: self.heightTabBar)
                }
            }
            
        } else if geture.state == .ended {
            if veclocitY > 900 {
                UIView.animate(withDuration: durationAnimation) {
                    viewPlayerVC.frame.origin.y = self.heightDevice -  MiniPlayerView.heightView -  self.heightTabBar
                    self.animationTarBar(y: self.heightTabBar)
                }
                return
            }
            
            if y >= 200 {
                UIView.animate(withDuration: durationAnimation) {
                    viewPlayerVC.frame.origin.y = self.heightDevice -  MiniPlayerView.heightView -  self.heightTabBar
                    self.animationTarBar(y: self.heightTabBar)
                }
            } else {
                UIView.animate(withDuration: durationAnimation) {
                    viewPlayerVC.frame.origin.y = -MiniPlayerView.heightView
                    self.animationTarBar(y: -self.heightTabBar)
                    
                }
            }
            
        }
    }
}

extension TabBarController: PlayerControllerDelegate {
    func presentPlayerVCFullScreen() {
        UIView.animate(withDuration: 0.25) {
            self.playerVC.view.frame.origin.y = -MiniPlayerView.heightView
            self.tabBar.frame.origin.y = self.heightDevice
            self.view.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
}
