//
//  ImportController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 13/08/2023.
//


import UIKit


class ImportController: BaseController {
    
    //MARK: - Properties

    
    //MARK: - UIComponent
    private lazy var titleLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Import"
        label.font = .fontRailwayBold(22)
        label.textColor = .white
        return label
    }()
    
    private lazy var importCL: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImportCLCell.self, forCellWithReuseIdentifier: ImportCLCell.cellId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureProperties()
    }
    
    func configureUI() {
        view.addSubview(importCL)
        view.addSubview(titleLbl)
        
        NSLayoutConstraint.activate([
            titleLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: isIphone ? 14 : 25),
            
            importCL.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 45),
            importCL.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            importCL.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            importCL.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
}

//MARK: - Method
extension ImportController {
    
    //MARK: - Helpers
    func configureProperties() {
        
    }
    
    //MARK: - Selectors
    
}


extension ImportController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImportType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImportCLCell.cellId,
                                                      for: indexPath) as! ImportCLCell
        cell.cellType = ImportType(rawValue: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 2 - 40, height: view.frame.width / 2 - 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let type = ImportType(rawValue: indexPath.row) else {return}

		switch type {
			case .googleDrive:
				let googleVC = GoogleDriveController(type: .googleDrive)
                self.tabBarController?.navigationController?.pushViewController(googleVC, animated: true)
			case .box:
				let importVC = BoxController(type: type)
				self.tabBarController?.navigationController?.pushViewController(importVC, animated: true)
			case .dropBox:
				let importVC = DropboxImportController(type: .dropBox)
				self.tabBarController?.navigationController?.pushViewController(importVC, animated: true)
			case .onedrive:
				let importVC = OneDriveImportController(type: .onedrive)
				self.tabBarController?.navigationController?.pushViewController(importVC, animated: true)
		}
    }
    
}

