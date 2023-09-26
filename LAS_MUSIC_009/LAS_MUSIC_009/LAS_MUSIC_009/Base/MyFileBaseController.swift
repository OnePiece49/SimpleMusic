//
//  MyFileBaseController.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 16/08/2023.
//

import UIKit

class MyFileBaseController: BaseController {

	let myfileType: MyFilesType

	// MARK: - UI components
	var navBar: NavigationCustomView!

	lazy var tableView: UITableView = {
		let tbv = UITableView(frame: .zero, style: .plain)
		tbv.translatesAutoresizingMaskIntoConstraints = false
		tbv.backgroundColor = .clear
		return tbv
	}()

	// MARK: - Life cycle
	init(type: MyFilesType) {
		self.myfileType = type
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setupNavBar()
		view.addSubview(navBar)
		view.addSubview(tableView)
		setupConstraints()
    }

	func setupConstraints() {
		navBar.anchor(leading: view.leadingAnchor,
					  top: view.safeAreaLayoutGuide.topAnchor,
					  trailing: view.trailingAnchor, height: 44)

		tableView.anchor(leading: view.leadingAnchor,
						 top: navBar.bottomAnchor,
						 trailing: view.trailingAnchor,
						 bottom: view.bottomAnchor)
	}

	func setupNavBar() {
		let firstAttributeLeft = AttibutesButton(image: UIImage(named: AssetConstant.ic_back)?.withRenderingMode(.alwaysOriginal),
												 sizeImage: CGSize(width: 24, height: 25)) { [weak self] in
			self?.navigationController?.popToRootViewController(animated: true)
		}

		self.navBar = NavigationCustomView(centerTitle: myfileType.title,
										   centertitleFont: .fontRailwayBold(18)!,
										   centerColor: UIColor(rgb: 0xEEEEEE),
										   attributeLeftButtons: [firstAttributeLeft],
										   attributeRightBarButtons: [],
										   isHiddenDivider: true,
										   beginSpaceLeftButton: 24)

		navBar.translatesAutoresizingMaskIntoConstraints = false
	}
}

