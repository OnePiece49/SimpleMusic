//
//  SearchController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 21/08/2023.
//

import UIKit
import UIScrollView_InfiniteScroll


class SearchController: BaseController {
    
    //MARK: - Properties
    let loadingMoreIndicator = UIActivityIndicatorView(style: .white)
    let viewModel = SearchViewModel()
    var shouldLoadMore = true

    //MARK: - UIComponent
    let searchingIndicator = UIActivityIndicatorView(style: .white)
    
    let searchView = CustomSearchBarView()

    private lazy var topSearchCL: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TopSearchCLCell.self,
                             forCellWithReuseIdentifier: TopSearchCLCell.cellId)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    
    lazy var searchResultTB: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .primaryBackgroundColor
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(rgb: 0xD8D8D8)
        tableView.register(SearchResultTBCell.self, forCellReuseIdentifier: SearchResultTBCell.cellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.infiniteScrollIndicatorView = loadingMoreIndicator
        tableView.infiniteScrollIndicatorMargin = 40
        tableView.infiniteScrollTriggerOffset = 500
        
        tableView.addInfiniteScroll { [weak self] tbView in
            self?.shouldLoadMore = false
            self?.viewModel.loadMore()
        }
        
        tableView.setShouldShowInfiniteScrollHandler { [weak self] tbView in
            guard let strongSelf = self else {return false}
            return strongSelf.shouldLoadMore && (strongSelf.searchResultTB.contentSize.height - strongSelf.heightDevice < strongSelf.searchResultTB.contentOffset.y)
        }
        return tableView
    }()
    
    private lazy var filterCL: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FilterCLCell.self,
                             forCellWithReuseIdentifier: FilterCLCell.cellId)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .init(top: 0, left: 24, bottom: 0, right: 0)
        return collectionView
    }()
    
    private lazy var historyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .fontRailwayBold(22)
        label.text = "History"
        label.textColor = UIColor(rgb: 0xEEEEEE)
        return label
    }()
    
    private lazy var containerTopSearchView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(historyLabel)
        view.addSubview(topSearchCL)
        topSearchCL.backgroundColor = .clear
        topSearchCL.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            historyLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            historyLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            
            topSearchCL.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 15),
            topSearchCL.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 18),
            topSearchCL.rightAnchor.constraint(equalTo: view.rightAnchor),
            topSearchCL.heightAnchor.constraint(equalToConstant: 35),
        ])
        return view
    }()
    
    //MARK: - View Lifecycle
    deinit {
        print("DEBUG: SearchVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureProperties()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		searchView.searchTextFiled.becomeFirstResponder()
	}
	
    func configureUI() {
        searchView.delegate = self
        view.addSubview(searchView)
        view.addSubview(containerTopSearchView)
        view.addSubview(filterCL)
        view.addSubview(searchResultTB)
        view.addSubview(searchingIndicator)
        searchingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        searchView.becomeFirstResponder()
        
        NSLayoutConstraint.activate([
            searchView.heightAnchor.constraint(equalToConstant: 46),
            searchView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            searchView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            containerTopSearchView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 24),
            containerTopSearchView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerTopSearchView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerTopSearchView.heightAnchor.constraint(equalToConstant: 95),
            
            filterCL.heightAnchor.constraint(equalToConstant: 46),
            filterCL.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            filterCL.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0),
            filterCL.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 29),
            
            searchResultTB.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            searchResultTB.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            searchResultTB.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0),
            searchResultTB.topAnchor.constraint(equalTo: filterCL.bottomAnchor, constant: 15),
            
            searchingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        searchingIndicator.setDimensions(width: 50, height: 50)
        
        filterCL.isHidden = true
        searchResultTB.isHidden = true
    }
    
}

//MARK: - Method
extension SearchController {
    
    //MARK: - Helpers
    func configureProperties() {
        viewModel.loadData()
        self.shouldLoadMore = false
        
        self.viewModel.bindingLoadmore = { [weak self] in
            self?.searchResultTB.reloadData()
            self?.shouldLoadMore = true
            self?.searchResultTB.finishInfiniteScroll()
            
        }
        
        self.viewModel.bindingSearching = { [weak self] in
            self?.searchResultTB.reloadData()
            self?.searchingIndicator.stopAnimating()
            self?.shouldLoadMore = true
        }
    }
    
    //MARK: - Selectors
    
}

// MARK: - SearchController delegate UICollectionViewDelegate, UICollectionViewDataSource
extension SearchController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topSearchCL {
            return viewModel.numberTopSearchCell
        }
        
        return SearchFilter.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topSearchCL {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopSearchCLCell.cellId,
                                                          for: indexPath) as! TopSearchCLCell
            cell.updateUI(text: viewModel.nameCellHistory(at: indexPath))
            return cell
            
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCLCell.cellId,
                                                      for: indexPath) as! FilterCLCell
        cell.celltype = SearchFilter(rawValue: indexPath.row)
        cell.updateSelected(isSelect: viewModel.filterSelected(filter: cell.celltype))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == filterCL {
            return CGSize(width: 75, height: 35)
        }
        
        let width = String.getSizeString(text: viewModel.nameCellHistory(at: indexPath),
                                         font: .fontRailwayBold(16)!).width
        
        let padding = 2 * (TopSearchCLCell.alightmentSearchCell + TopSearchCLCell.aligmentSearchLabel)

        if width > 200 {
            return CGSize(width: 200 + padding , height: 35)
        }
        
        return CGSize(width: width + padding + 10, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == filterCL {
            return 4
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == filterCL {
            self.viewModel.filter = SearchFilter(rawValue: indexPath.row) ?? .music
            self.filterCL.reloadData()
            
            guard let text = searchView.searchTextFiled.text, text != "" else {return}
            let shouldLoad = viewModel.shoudLoadNewFilter(text: text)
            
            if shouldLoad {
                self.searchingIndicator.startAnimating()
                self.viewModel.reloadData()
                self.searchResultTB.reloadData()
                self.viewModel.searchQuery(with: text)
            } else {
                self.searchResultTB.reloadData()
            }
        } else if collectionView == topSearchCL {
            let music = viewModel.cellTopHistory(at: indexPath)
            guard let playlist = viewModel.historyPlaylist else {return}
            
            self.playMusic(playlist: playlist, currentMusic: music)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: - SearchController delegate UITableViewDelegate, UITableViewDataSource
extension SearchController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTBCell.cellId,
                                                 for: indexPath) as! SearchResultTBCell
        cell.delegate = self
        cell.musicModel = viewModel.musicForCell(at: indexPath)        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = viewModel.musicForCell(at: indexPath)
        guard let playlist = viewModel.getPlaylist(at: indexPath) else {return}
        
        self.playMusic(playlist: playlist, currentMusic: music)
        self.viewModel.saveTopSearch(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchResultTBCell.cellHeight
    }
}

// MARK: - SearchController delegate CustomSearchBarDelegate
extension SearchController: CustomSearchBarDelegate {
    func didEndSearching(textField: UITextField) {
        guard let text = textField.text, text != "" else {return}
        
        containerTopSearchView.isHidden = true
        filterCL.isHidden = false
        searchResultTB.isHidden = false
        
        let status = viewModel.searchQuery(with: text)
        
        if status == .willSearching {
            self.searchingIndicator.startAnimating()
        }
    }

    func didSelectCancelButton() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - SearchController delegate MoreSheetSearchVDelegate, SearchResultTBCellDelegate
extension SearchController: MoreSheetSearchVDelegate, SearchResultTBCellDelegate {
    func didSelectOption(option: MoreSheetSearchOption?, music: MusicModel) {
        switch option {
        case .addToPlaylist:
            let addToVc = AddToPlaylistController(music: music)
            self.present(addToVc, animated: true)
        case .addToFav:
            let success = viewModel.saveFavourite(music: music)
            
            let message = success ? "Save to Favourite successfully" : "Save to Favourite failed, video is existed"
            self.view.displayToast(message)
        default:
            return
            
        }
    }
    
    func didSelectMore(_ cell: SearchResultTBCell) {
        guard let indexPath = searchResultTB.indexPath(for: cell) else {return}
        let music = viewModel.musicForCell(at: indexPath)
        let vc = MoreSheetSearchController(music: music, sourceType: .online)
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false) {
            vc.showSheet()
        }
    }
}
