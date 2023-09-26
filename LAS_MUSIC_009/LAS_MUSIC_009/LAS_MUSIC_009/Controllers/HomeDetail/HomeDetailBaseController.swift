//
//  HomeDetailBaseController.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 29/08/2023.
//

import UIKit

class HomeDetailBaseController: BaseController {

	var viewModel: HomeDetailViewModel? {
		didSet { updateUI() }
	}
	private var centerTitle: String?
	private var lastSelectedIndexPath: IndexPath?

	// MARK: - UI components
	var navBar: NavigationCustomView!

	let loadingIndicator: UIActivityIndicatorView = {
		var view: UIActivityIndicatorView
		if #available(iOS 13.0, *) {
			view = UIActivityIndicatorView(style: .large)
			view.color = .white
		} else {
			view = UIActivityIndicatorView(style: .white)
		}
		view.translatesAutoresizingMaskIntoConstraints = false
		view.hidesWhenStopped = true
		view.startAnimating()
		return view
	}()

	let headerLayerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	lazy var shuffleBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setImage(UIImage(named: AssetConstant.ic_not_random)?.withRenderingMode(.alwaysOriginal), for: .normal)
		btn.addTarget(self, action: #selector(shuffleBtnTapped), for: .touchUpInside)
		return btn
	}()

	lazy var replayModeBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setImage(UIImage(named: AssetConstant.ic_not_replay)?.withRenderingMode(.alwaysOriginal), for: .normal)
		btn.addTarget(self, action: #selector(replayBtnTapped), for: .touchUpInside)
		return btn
	}()

	lazy var playBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setImage(UIImage(named: AssetConstant.ic_mini_play), for: .normal)
		btn.tintColor = .white
		btn.contentVerticalAlignment = .fill
		btn.contentHorizontalAlignment = .fill
		btn.addTarget(self, action: #selector(playBtnTapped), for: .touchUpInside)
		return btn
	}()

	lazy var musicTbv: UITableView = {
		let tbv = UITableView(frame: .zero, style: .plain)
		tbv.translatesAutoresizingMaskIntoConstraints = false
		tbv.backgroundColor = .clear
		tbv.register(PlaylistDetailTBCell.self, forCellReuseIdentifier: PlaylistDetailTBCell.cellId)
		tbv.delegate = self
		tbv.dataSource = self
		return tbv
	}()

	// MARK: - Lifecycle
	init(title: String?) {
		self.centerTitle = title
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavBar()
		setupConstraints()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		headerLayerView.applyGradient(colours: [UIColor(rgb: 0x1F1F1F), UIColor(rgb: 0x333333)],
									  startPoint: CGPoint(x: 0, y: 0),
									  endPoint: CGPoint(x: 0, y: 1))
	}

	func setupNavBar() {
		let firstAttributeLeft = AttibutesButton(image: UIImage(named: AssetConstant.ic_back)?.withRenderingMode(.alwaysOriginal),
												 sizeImage: CGSize(width: 24, height: 25)) { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		self.navBar = NavigationCustomView(centerTitle: centerTitle,
										   centertitleFont: .fontRailwayBold(18)!,
										   centerColor: UIColor(rgb: 0xEEEEEE),
										   attributeLeftButtons: [firstAttributeLeft],
										   attributeRightBarButtons: [],
										   isHiddenDivider: true,
										   beginSpaceLeftButton: 24)
		navBar.translatesAutoresizingMaskIntoConstraints = false
	}

	func setupConstraints() {
		let actionStack = UIStackView(arrangedSubviews: [shuffleBtn, playBtn, replayModeBtn])
		actionStack.spacing = isIphone ? 46 : 64
		actionStack.alignment = .center

		view.addSubview(headerLayerView)
		view.addSubview(navBar)
		view.addSubview(actionStack)
		view.addSubview(musicTbv)
		view.addSubview(loadingIndicator)

		// navbar
		navBar.anchor(leading: view.leadingAnchor,
					  top: view.safeAreaLayoutGuide.topAnchor,
					  trailing: view.trailingAnchor, height: 44)

		// header layer view
		headerLayerView.anchor(leading: view.leadingAnchor,
							   top: view.topAnchor,
							   trailing: view.trailingAnchor,
							   bottom: actionStack.bottomAnchor)

		// action stack view
		actionStack.anchor(top: navBar.bottomAnchor, height: 74)
		actionStack.centerX(centerX: view.centerXAnchor)

		playBtn.setDimensions(width: 42, height: 42)
		shuffleBtn.setDimensions(width: 24, height: 24)
		replayModeBtn.setDimensions(width: 24, height: 24)

		// music table view
		musicTbv.anchor(leading: view.leadingAnchor,
						top: headerLayerView.bottomAnchor,
						trailing: view.trailingAnchor,
						bottom: view.bottomAnchor)

		// loading indicator
		loadingIndicator.centerX(centerX: musicTbv.centerXAnchor)
		loadingIndicator.centerY(centerY: musicTbv.centerYAnchor, paddingY: -40)
	}

}

// MARK: - Methods
extension HomeDetailBaseController {
	@objc func shuffleBtnTapped() {
		viewModel?.toggleShuffleMode()
	}

	@objc func replayBtnTapped() {
		viewModel?.toggleReplayMode()
	}

	@objc func playBtnTapped() {
		self.openMainPlayer(indexPath: IndexPath(row: 0, section: 0))
	}

	private func updateUI() {
		bindViewModel()
		loadingIndicator.stopAnimating()
		musicTbv.reloadData()
	}

	private func bindViewModel() {
		guard let viewModel = viewModel else { return }

		viewModel.onToggleShuffle = { [weak self] in
			guard let self = self else { return }
			self.shuffleBtn.setImage(UIImage(named: viewModel.shuffleBtnImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
			self.musicTbv.reloadData()
		}

		viewModel.onToggleReplay = { [weak self] in
			guard let self = self else { return }
			self.replayModeBtn.setImage(UIImage(named: viewModel.replayBtnImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
		}
	}

	private func openMainPlayer(indexPath: IndexPath) {
		guard let viewModel = viewModel else { return }
		let playlist = viewModel.getPlaylist()
		let music = viewModel.getMusicModel(at: indexPath)
		let replayMode = viewModel.replayMode
		self.playMusic(playlist: playlist, currentMusic: music, replayMode: replayMode)
		self.navigationController?.popToRootViewController(animated: true)
	}
}

// MARK: - PlaylistDetailTBCellDelegate
extension HomeDetailBaseController: PlaylistDetailTBCellDelegate {
	func didSelectMore(_ cell: PlaylistDetailTBCell) {
		guard let music = cell.viewModel?.music else { return }
		lastSelectedIndexPath = musicTbv.indexPath(for: cell)

		let vc = HomeDetailSheetController(music: music)
		vc.delegate = self
		vc.modalPresentationStyle = .overFullScreen
		self.present(vc, animated: false) {
			vc.showSheet()
		}
	}
}

// MARK: - HomeDetailSheetControllerDelegate
extension HomeDetailBaseController: HomeDetailSheetControllerDelegate {
	func didTapAddToPlaylist(_ controller: HomeDetailSheetController, music: MusicModel) {
		let vc = AddToPlaylistController(music: music)
		self.present(vc, animated: true)
	}

	func didTapShare(_ controller: HomeDetailSheetController, music: MusicModel) {
		guard music.sourceType == .online else { return }
		let objectsToShare: [Any] = [music.remotePath as Any]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

		if let indexPath = self.lastSelectedIndexPath, let cell = self.musicTbv.cellForRow(at: indexPath) {
			activityVC.popoverPresentationController?.sourceView = cell
		}
		self.present(activityVC, animated: true, completion: nil)
	}
}

// MARK: - UITableViewDelegate
extension HomeDetailBaseController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel?.numberOfItems ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistDetailTBCell.cellId,
												 for: indexPath) as! PlaylistDetailTBCell
		if let music = viewModel?.getMusicModel(at: indexPath) {
			cell.viewModel = PlaylistDetailCellViewModel(music: music, indexPath: indexPath)
		}
		cell.delegate = self
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		self.openMainPlayer(indexPath: indexPath)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return PlaylistDetailTBCell.cellHeight
	}
}
