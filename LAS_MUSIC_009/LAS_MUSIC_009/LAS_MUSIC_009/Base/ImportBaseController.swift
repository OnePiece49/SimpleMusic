//
//  ImportBaseController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 13/08/2023.
//

import UIKit

enum ImportType: Int, CaseIterable {
    case googleDrive
    case box
    case dropBox
    case onedrive
    
    var title: String {
		switch self {
			case .googleDrive: return "Google Drive"
			case .box: return "Box"
			case .dropBox: return "Drop Box"
			case .onedrive: return "One Drive"
        }
    }

	var image: UIImage? {
		switch self {
			case .googleDrive: return UIImage(named: AssetConstant.ic_google_drive)
			case .box: return UIImage(named: AssetConstant.ic_box)
			case .dropBox: return UIImage(named: AssetConstant.ic_dropBox)
			case .onedrive: return UIImage(named: AssetConstant.ic_onedrive)
		}
	}
}


class ImportBaseController: BaseController {
    
    //MARK: - Properties
    let importType: ImportType
    
    //MARK: - UIComponent
    let loadingIndicator: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let view = UIActivityIndicatorView(style: .large)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.color = .white
			view.hidesWhenStopped = true
            return view
        } else {
            let view = UIActivityIndicatorView(style: .white)
            view.translatesAutoresizingMaskIntoConstraints = false
			view.hidesWhenStopped = true
            return view
        }
    }()
    
    lazy var downloadTB: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .primaryBackgroundColor
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(rgb: 0xD8D8D8)
        tableView.register(BaseImportTBCell.self, forCellReuseIdentifier: BaseImportTBCell.cellId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var navBar: NavigationCustomView!
    
    lazy var signinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN IN", for: .normal)
        button.contentMode = .scaleToFill
        button.tintColor = UIColor(rgb: 0xCBFB5E)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.titleLabel?.font = .fontRailwayBold(16)
        button.layer.borderColor = UIColor(rgb: 0xCBFB5E).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - View Lifecycle
    init(type: ImportType) {
        self.importType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        view.addSubview(signinButton)
        createNavigationBar()
        view.addSubview(navBar)
        view.addSubview(downloadTB)
        view.addSubview(loadingIndicator)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navBar.heightAnchor.constraint(equalToConstant: 48),
            navBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            signinButton.heightAnchor.constraint(equalToConstant: 48),
            signinButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            signinButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            signinButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            downloadTB.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 25),
            downloadTB.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            downloadTB.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0),
            downloadTB.bottomAnchor.constraint(equalTo: signinButton.topAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func updateCenterNav(with email: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributedTitle = NSMutableAttributedString(string: "\(importType.title)\n",
														attributes: [.font: UIFont.fontRailwayBold(18),
																	 .foregroundColor: UIColor.white])
		attributedTitle.append(NSAttributedString(string: email,
												  attributes: [.font: UIFont.fontRailwayRegular(12),
															   .foregroundColor: UIColor.secondaryYellow]))
        attributedTitle.addAttribute(NSAttributedString.Key.paragraphStyle,
									 value:paragraphStyle,
									 range:NSMakeRange(0, attributedTitle.length))
        paragraphStyle.lineSpacing = 5
        
        self.navBar.titleLabel.attributedText = attributedTitle
        if email == "" {
            self.navBar.titleLabel.numberOfLines = 1
        } else {
            self.navBar.titleLabel.numberOfLines = 2
        }
        
    }
    
    func createNavigationBar() {
        let firstAttributeLeft = AttibutesButton(image: UIImage(named: AssetConstant.ic_back)?.withRenderingMode(.alwaysOriginal),
                                                 sizeImage: CGSize(width: 24, height: 25)) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        self.navBar = NavigationCustomView(centerTitle: importType.title,
                                          attributeLeftButtons: [firstAttributeLeft],
                                          attributeRightBarButtons: [],
                                          isHiddenDivider: true,
                                          beginSpaceLeftButton: 24)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        updateCenterNav(with: "")
    }
    
}

//MARK: - Method
extension ImportBaseController {
    
    //MARK: - Helpers
    
    //MARK: - Selectors
    
}
