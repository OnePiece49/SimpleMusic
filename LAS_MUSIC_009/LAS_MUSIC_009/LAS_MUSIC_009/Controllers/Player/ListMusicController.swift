//
//  ListMusicController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 23/08/2023.
//


import UIKit
import MediaPlayer

protocol ListMusicControllerDelegate: AnyObject {
    func didSelectMediaCell(music: MusicModel)
}

class ListMusicController: BottomSheetViewCustomController {

    //MARK: - Properties
    let playlist: PlaylistModel
	var currentIndex: Int {
		didSet {
			tableView.reloadData()
		}
	}
	weak var delegate: ListMusicControllerDelegate?

    var navigationBar: NavigationCustomView!

	let tableView: UITableView = {
		let tbv = UITableView(frame: .zero, style: .plain)
		tbv.translatesAutoresizingMaskIntoConstraints = false
		tbv.backgroundColor = .clear
		return tbv
	}()

	let containerView: UIView = {
		let view = UIView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .primaryBackgroundColor
		view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		view.layer.cornerRadius = 20
		view.clipsToBounds = true
		return view
	}()
    
    override var durationAnimation: CGFloat {
        return 0.3
    }
    
    override var bottomSheetView: UIView {
        return containerView
    }
    
    override var heightBottomSheetView: CGFloat {
        return view.frame.height - 180
    }
    
    override var maxHeightScrollTop: CGFloat {
        return 40
    }
    
    override var minHeightScrollBottom: CGFloat {
        return 300
    }
    
    //MARK: - View Lifecycle
    init(playlist: PlaylistModel, currentIndex: Int) {
        self.playlist = playlist
        self.currentIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureProperties()
    }
    
    deinit {
        print("DEBUG: ListMusicController deinit")
    }
    
    //MARK: - Helpers
    private func configureUI() {
        configureNaviationBar()
        containerView.addSubview(navigationBar)
        containerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            navigationBar.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 45),
            
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 10),
            tableView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -45),
        ])
    }
    
    private func configureProperties() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListMusicTBCell.self, forCellReuseIdentifier: ListMusicTBCell.cellId)
    }
    
    private func configureNaviationBar() {
        let firstAttributeLeft = AttibutesButton(image: UIImage(named: "ic_add_song"),
												 sizeImage: CGSize(width: 24, height: 25),
                                                 tincolor: .white)
        
        let secondAttributeLeft = AttibutesButton(tilte: "List Song",
                                                 font: .boldSystemFont(ofSize: 16),
                                                 titleColor: .white)
        
        let attributeRight = AttibutesButton(tilte: "Cancel",
                                             font: .boldSystemFont(ofSize: 16),
											 titleColor: .secondaryYellow) { [weak self] in
            self?.animationDismiss()
        }
         
         self.navigationBar = NavigationCustomView(centerTitle: "",
                                                   attributeLeftButtons: [firstAttributeLeft, secondAttributeLeft],
                                                   attributeRightBarButtons: [attributeRight],
                                                   isHiddenDivider: true,
                                                   beginSpaceLeftButton: 20,
                                                   beginSpaceRightButton: 20)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate
extension ListMusicController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.musics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListMusicTBCell.cellId,
                                                 for: indexPath) as! ListMusicTBCell
        
        cell.music = playlist.musics[indexPath.row]
        cell.shouldHiddenPlayButton(isHidden: indexPath.row != currentIndex)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = playlist.musics[indexPath.row]
        self.currentIndex = indexPath.row
        self.tableView.reloadData()
        self.delegate?.didSelectMediaCell(music: music)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ListMusicTBCell.heightCell
    }

}

