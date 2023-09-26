//
//  HomeVC.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 31/08/2023.
//

import UIKit

class HomeVC: BaseController {

	var cellIndentifiers: [String] = [
		HomeAlbumTBVCell.cellId,
		HomeChartTBVCell.cellId,
		HomeTrendingTBVCell.cellId,
		HomeTopicTBVCell.cellId
	]

	let albumVM = HomeAlbumVM()
	let chartVM = HomeChartVM()
	let trendingVM = HomeTrendingVM()
	let topicVM = HomeTopicVM()

	//MARK: - UIComponent
	let searchView = CustomSearchBarView(ishiddenCancelButton: true)

	private lazy var homeTbv: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(HomeAlbumTBVCell.self, forCellReuseIdentifier: HomeAlbumTBVCell.cellId)
		tableView.register(HomeChartTBVCell.self, forCellReuseIdentifier: HomeChartTBVCell.cellId)
		tableView.register(HomeTrendingTBVCell.self, forCellReuseIdentifier: HomeTrendingTBVCell.cellId)
		tableView.register(HomeTopicTBVCell.self, forCellReuseIdentifier: HomeTopicTBVCell.cellId)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.backgroundColor = UIColor(rgb: 0x1C1B1F)
		tableView.contentInset = .init(top: 0, left: 0, bottom: MiniPlayerView.heightView + 10, right: 0)
		return tableView
	}()

	//MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		configureUI()
		bindViewModel()
		observeNotification()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	func configureUI() {
		view.addSubview(homeTbv)
		view.addSubview(searchView)

		searchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUserSearchTapped)))
		searchView.isUserInteractionEnabled = true
		searchView.translatesAutoresizingMaskIntoConstraints = false
		searchView.searchTextFiled.isUserInteractionEnabled = false

		NSLayoutConstraint.activate([
			searchView.heightAnchor.constraint(equalToConstant: 46),
			searchView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
			searchView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
			searchView.topAnchor.constraint(equalTo: view.topAnchor, constant: 52),

			homeTbv.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 25),
			homeTbv.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
			homeTbv.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -0),
			homeTbv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
		])
	}

	@objc func handleUserSearchTapped() {
		let searchVC = SearchController()
		self.navigationController?.pushViewController(searchVC, animated: true)
	}
}

// MARK: - Methods
extension HomeVC {
	private func bindViewModel() {
		// album
		albumVM.onGetAlbums = { [weak self] in
            DispatchQueue.main.async {
                self?.homeTbv.reloadData()
            }
			
		}
		albumVM.getAllAlbums()

		// chart
		chartVM.onGetMusicChart = { [weak self] in
            DispatchQueue.main.async {
                self?.homeTbv.reloadData()
            }
			
		}
		chartVM.getMusicChart()

		// trending
		trendingVM.onGetTrendingMusics = { [weak self] in
            DispatchQueue.main.async {
                self?.homeTbv.reloadData()
            }
			
		}
		trendingVM.getTrendingMusics()

		// topic
		topicVM.onGetGenres = { [weak self] in
            DispatchQueue.main.async {
                self?.homeTbv.reloadData()
            }
			
		}
		topicVM.getAllGenres()
	}

	private func observeNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateFavoriteMusicFromPlayer),
											   name: .updateLikeButtonToOtherControllers, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updateFavoriteMusicFromPlayer),
											   name: .updateLikeButtonToPlayerController, object: nil)
	}

	@objc private func updateFavoriteMusicFromPlayer(_ notification: Notification) {
		guard let music = notification.userInfo?["music"] as? MusicModel else { return }

		guard let index = cellIndentifiers.firstIndex(of: HomeTrendingTBVCell.cellId),
			  let trendingCell = homeTbv.cellForRow(at: IndexPath(row: index, section: 0)) as? HomeTrendingTBVCell
		else { return }

		trendingCell.updateFavoriteMusic(music)
	}
}

// MARK: - UITableViewDelegate
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cellIndentifiers.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch cellIndentifiers[indexPath.row] {
			case HomeAlbumTBVCell.cellId:
				let cell = tableView.dequeueReusableCell(withIdentifier: HomeAlbumTBVCell.cellId,
														 for: indexPath) as! HomeAlbumTBVCell
				cell.selectionStyle = .none
				cell.delegate = self
				cell.albums = albumVM.albums
				return cell

			case HomeChartTBVCell.cellId:
				let cell = tableView.dequeueReusableCell(withIdentifier: HomeChartTBVCell.cellId,
														 for: indexPath) as! HomeChartTBVCell
				cell.selectionStyle = .none
				cell.delegate = self
				cell.musics = chartVM.musics
				return cell

			case HomeTrendingTBVCell.cellId:
				let cell = tableView.dequeueReusableCell(withIdentifier: HomeTrendingTBVCell.cellId,
														 for: indexPath) as! HomeTrendingTBVCell
				cell.selectionStyle = .none
				cell.delegate = self
				cell.musics = trendingVM.musics
				return cell

			case HomeTopicTBVCell.cellId:
				let cell = tableView.dequeueReusableCell(withIdentifier: HomeTopicTBVCell.cellId,
														 for: indexPath) as! HomeTopicTBVCell
				cell.selectionStyle = .none
				cell.delegate = self
				cell.genres = topicVM.genres
				return cell

			default:
				return UITableViewCell()
		}
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch cellIndentifiers[indexPath.row] {
			case HomeAlbumTBVCell.cellId:
				return HomeAlbumTBVCell.cellHeight

			case HomeChartTBVCell.cellId:
				return HomeChartTBVCell.cellHeight

			case HomeTopicTBVCell.cellId:
				return HomeTopicTBVCell.cellHeight

			case HomeTrendingTBVCell.cellId:
				return HomeTrendingTBVCell.cellHeight

			default:
				return 0
		}
	}
}

// MARK: - Album Delegate
extension HomeVC: HomeAlbumTBVCellDelegate {
	func didSelectViewAllButton() {
		let albumVC = FullAlbumsController()
		self.navigationController?.pushViewController(albumVC, animated: true)
	}

	func didSelectHomeAlbumsCell(album: YTAblumModel) {
		let vc = HomeDetailBaseController(title: album.title)
		albumVM.getAlbumDetail(album: album) { tracks in
			vc.viewModel = HomeDetailViewModel(musics: tracks)
		}
		self.navigationController?.pushViewController(vc, animated: true)
	}
}

// MARK: - Chart Delegate
extension HomeVC: HomeChartTBVCellDelegate {
	func didTapViewAll(_ cell: HomeChartTBVCell) {
		let musics = cell.musics
		let chartVM = HomeDetailViewModel(musics: musics)
		let vc = HomeDetailBaseController(title: "Music Chart")
		vc.viewModel = chartVM
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func didSelectMore(_ cell: HomeChartTBVCell, music: MusicModel) {
		let vc = HomeDetailSheetController(music: music)
		vc.delegate = self
		vc.modalPresentationStyle = .overFullScreen
		self.present(vc, animated: false) {
			vc.showSheet()
		}
	}

	func didTapPlayMusic(_ cell: HomeChartTBVCell, music: MusicModel) {
		self.playMusic(playlist: chartVM.getPlaylistModel(), currentMusic: music)
	}
}

// MARK: - HomeDetailSheetControllerDelegate
extension HomeVC: HomeDetailSheetControllerDelegate {
	func didTapAddToPlaylist(_ controller: HomeDetailSheetController, music: MusicModel) {
		controller.removeSheet {
			let vc = AddToPlaylistController(music: music)
			self.present(vc, animated: true)
		}
	}

	func didTapShare(_ controller: HomeDetailSheetController, music: MusicModel) {
		controller.removeSheet {
			guard music.sourceType == .online else { return }
			let objectsToShare: [Any] = [music.remotePath as Any]
			let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
			let cell = self.homeTbv.cellForRow(at: IndexPath(row: 1, section: 0))
			activityVC.popoverPresentationController?.sourceView = cell
			self.present(activityVC, animated: true, completion: nil)
		}
	}
}

// MARK: - Trending Delegate
extension HomeVC: HomeTrendingTBVCellDelegate {
	func didTapViewAll(_ cell: HomeTrendingTBVCell) {
		let musics = cell.musics
		let trendingVM = HomeDetailViewModel(musics: musics)
		let vc = HomeDetailBaseController(title: "Top Trending")
		vc.viewModel = trendingVM
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func didTapPlayMusic(_ cell: HomeTrendingTBVCell, music: MusicModel) {
		self.playMusic(playlist: trendingVM.getPlaylistModel(), currentMusic: music)
	}

	func didTapFavoriteMusic(_ cell: HomeTrendingTBVCell, music: MusicModel) {
		NotificationCenter.default.post(name: .updateLikeButtonToPlayerController, object: nil, userInfo: ["music": music])
	}
}

// MARK: - Topic Delegate
extension HomeVC: HomeTopicTBVCellDelegate {
	func didTapViewAll(_ cell: HomeTopicTBVCell) {
		let genres = cell.genres
		let vc = FullTopicsController(viewModel: FullTopicsViewModel(genres: genres))
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func didTapOpenGenre(_ cell: HomeTopicTBVCell, genre: YTGenresModel) {
		let vc = HomeDetailBaseController(title: genre.title)
		topicVM.getGenrePLaylistDetail(genre: genre) { tracks in
			vc.viewModel = HomeDetailViewModel(musics: tracks)
		}
		self.navigationController?.pushViewController(vc, animated: true)
	}
}
