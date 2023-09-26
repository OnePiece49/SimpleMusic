//
//  MyFilesController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 13/08/2023.
//

import UIKit

enum MyFilesType: Int, CaseIterable {
	case playlist
	case audio
	case imported
	case favourite

	var title: String {
		switch self {
			case .playlist: return "Playlist"
			case .audio: return "Audio"
			case .imported: return "Imported"
			case .favourite: return "Favourite"
		}
	}

	var image: UIImage? {
		switch self {
			case .playlist: return UIImage(named: AssetConstant.ic_playlist)
			case .audio: return UIImage(named: AssetConstant.ic_audio)
			case .imported: return UIImage(named: AssetConstant.ic_downloaded)
			case .favourite: return UIImage(named: AssetConstant.ic_favourite)
		}
	}

	var backgroundColor: UIColor {
		switch self {
			case .playlist: return UIColor(rgb: 0xF4FE88)
            case .audio, .imported, .favourite: return UIColor(rgb: 0x88FAFE)
		}
	}
}

class MyFilesController: BaseController {
    
    //MARK: - Properties
    
    
    //MARK: - UIComponent
	private lazy var downloadTB: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(MyFilesTBCell.self, forCellReuseIdentifier: MyFilesTBCell.cellId)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.isScrollEnabled = false
		return tableView
	}()

	private lazy var titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "My Files"
		label.font = .fontRailwayBold(22)
		label.textColor = .white
		return label
	}()
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureProperties()
    }
    
    func configureUI() {
        view.addSubview(downloadTB)
        view.addSubview(titleLbl)
        
        NSLayoutConstraint.activate([
            titleLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: isIphone ? 14 : 25),
            
            downloadTB.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 15),
            downloadTB.leftAnchor.constraint(equalTo: view.leftAnchor),
            downloadTB.rightAnchor.constraint(equalTo: view.rightAnchor),
            downloadTB.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
}

//MARK: - Method
extension MyFilesController {
    
    //MARK: - Helpers
    func configureProperties() {
        
    }
    
    //MARK: - Selectors
    
}


extension MyFilesController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyFilesType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyFilesTBCell.cellId,
                                                 for: indexPath) as! MyFilesTBCell
		cell.celltype = MyFilesType(rawValue: indexPath.row)
        cell.selectionStyle = .none
		cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MyFilesTBCell.heightCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let type = MyFilesType(rawValue: indexPath.row) else { return }

		switch type {
			case .playlist:
				let playlistVC = PlaylistGeneralController(type: .playlist)
				self.navigationController?.pushViewController(playlistVC, animated: true)
			case .audio:
                let audioConvertedVC = AudioConvertedController(type: .audio)
                self.navigationController?.pushViewController(audioConvertedVC, animated: true)
			case .imported:
				let importedVC = ImportedDetailController(type: .imported)
				self.tabBarController?.navigationController?.pushViewController(importedVC, animated: true)
			case .favourite:
				let favouriteVC = FavouriteDetailController(type: .favourite)
				self.navigationController?.pushViewController(favouriteVC, animated: true)
		}
    }
}

