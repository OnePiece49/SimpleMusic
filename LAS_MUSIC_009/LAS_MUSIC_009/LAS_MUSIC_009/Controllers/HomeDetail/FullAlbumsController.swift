//
//  FullAlbumsController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 28/08/2023.
//

import UIKit

class FullAlbumsController: BaseController {
    
    //MARK: - Properties
    let viewModel = FullAlbumsVIewModel()

    
    //MARK: - UIComponent
    let loadingIndicator = UIActivityIndicatorView(style: .white)
    var navBar: NavigationCustomView!
    
    private lazy var albumsTB: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AlbumTBCell.self, forCellReuseIdentifier: AlbumTBCell.cellId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        loadData()
    }
    
    func loadData() {
        viewModel.bindingViewModel = { [weak self] in
            self?.albumsTB.reloadData()
            self?.loadingIndicator.stopAnimating()
        }
        
        viewModel.loadData()
    }
    
    func configureUI() {
        configureNavBar()
        
        view.addSubview(navBar)
        view.addSubview(albumsTB)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            navBar.heightAnchor.constraint(equalToConstant: 44),
            navBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            albumsTB.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 10),
            albumsTB.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            albumsTB.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0),
            albumsTB.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        loadingIndicator.setDimensions(width: 35, height: 35)
        loadingIndicator.startAnimating()
    }
    
    private func configureNavBar() {
        let firstAttributeLeft = AttibutesButton(image: UIImage(named: AssetConstant.ic_back)?.withRenderingMode(.alwaysOriginal),
                                                 sizeImage: CGSize(width: 35, height: 35)) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        
        let attributedTitle = NSMutableAttributedString(string: "Albums",
                                                        attributes: [.font: UIFont.fontRailwayBold(20),
                                                                     .foregroundColor: UIColor.white])
        
        self.navBar = NavigationCustomView(centerTitle: "",
                                           attributedTitle: attributedTitle,
                                          attributeLeftButtons: [firstAttributeLeft],
                                          attributeRightBarButtons: [],
                                          isHiddenDivider: true,
                                          beginSpaceLeftButton: 24)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.backgroundColor = .clear
    }
    
}

//MARK: - Method
extension FullAlbumsController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numbersCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTBCell.cellId,
                                                 for: indexPath) as! AlbumTBCell
        
        cell.album = viewModel.albumForCell(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

        let album = viewModel.albumForCell(at: indexPath)
        let vc = HomeDetailBaseController(title: album.title)
        YTMManager.shared.getAlbumDetail(album: album) { ytmusics in
            
            let musics = ConvertService.shared.convertArrYTSearchToArrMSModel(ytSearchs: ytmusics)
            let detailVM = HomeDetailViewModel(musics: musics)
            vc.viewModel = detailVM
            
        }
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BaseMyFileTBCell.cellHeight
    }
    
}

