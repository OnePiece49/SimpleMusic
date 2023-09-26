//
//  PlaylistDetailController.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 16/08/2023.
//

import UIKit

protocol PlaylistDetailControllerDelegate: AnyObject {
	func playlistDidChange(_ controller: PlaylistDetailController, playlist: PlaylistModel)
}

class PlaylistDetailController: BaseController {

	private let viewModel: PlaylistDetailViewModel
	private var lastSelectedIndexPath: IndexPath?
	private let noDataView = NoDataView()

	weak var delegate: PlaylistDetailControllerDelegate?

	// MARK: - UI components
	private lazy var createPlaylistView: CreatePlaylistView = {
		let view = CreatePlaylistView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.option = .rename
		view.delegate = self
		return view
	}()

	private var navBar: NavigationCustomView!

	private let headerLayerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var shuffleBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setImage(UIImage(named: AssetConstant.ic_not_random)?.withRenderingMode(.alwaysOriginal), for: .normal)
		btn.addTarget(self, action: #selector(shuffleBtnTapped), for: .touchUpInside)
		return btn
	}()

	private lazy var replayModeBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setImage(UIImage(named: AssetConstant.ic_not_replay)?.withRenderingMode(.alwaysOriginal), for: .normal)
		btn.addTarget(self, action: #selector(replayBtnTapped), for: .touchUpInside)
		return btn
	}()

	private lazy var playBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setImage(UIImage(named: AssetConstant.ic_mini_play), for: .normal)
		btn.tintColor = .white
		btn.contentVerticalAlignment = .fill
		btn.contentHorizontalAlignment = .fill
		btn.addTarget(self, action: #selector(playBtnTapped), for: .touchUpInside)
		return btn
	}()

	private let musicTbv: UITableView = {
		let tbv = UITableView(frame: .zero, style: .plain)
		tbv.translatesAutoresizingMaskIntoConstraints = false
		tbv.backgroundColor = .clear
		return tbv
	}()

	// MARK: - Life cycle
	init(viewModel: PlaylistDetailViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavBar()
		setupTBView()
		setupConstraints()
		bindViewModel()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		headerLayerView.applyGradient(colours: [UIColor(rgb: 0x1F1F1F), UIColor(rgb: 0x333333)],
									  startPoint: CGPoint(x: 0, y: 0),
									  endPoint: CGPoint(x: 0, y: 1))
	}

	private func setupNavBar() {
		let firstAttributeLeft = AttibutesButton(image: UIImage(named: AssetConstant.ic_back)?.withRenderingMode(.alwaysOriginal),
												 sizeImage: CGSize(width: 24, height: 25)) { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		self.navBar = NavigationCustomView(centerTitle: viewModel.getRealPlaylist().name,
										   centertitleFont: .fontRailwayBold(18)!,
										   centerColor: UIColor(rgb: 0xEEEEEE),
										   attributeLeftButtons: [firstAttributeLeft],
										   attributeRightBarButtons: [],
										   isHiddenDivider: true,
										   beginSpaceLeftButton: 24)

		navBar.backgroundColor = .clear
		navBar.translatesAutoresizingMaskIntoConstraints = false
	}

	private func setupTBView() {
		musicTbv.delegate = self
		musicTbv.dataSource = self
		musicTbv.register(PlaylistDetailTBCell.self, forCellReuseIdentifier: PlaylistDetailTBCell.cellId)
	}

	private func setupConstraints() {
		let actionStack = UIStackView(arrangedSubviews: [shuffleBtn, playBtn, replayModeBtn])
		actionStack.spacing = isIphone ? 46 : 64
		actionStack.alignment = .center

		view.addSubview(headerLayerView)
		view.addSubview(navBar)
		view.addSubview(actionStack)
		view.addSubview(musicTbv)
		view.addSubview(createPlaylistView)

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

		// create playlist view
		createPlaylistView.pinToView(view)
	}
}

// MARK: - Method
extension PlaylistDetailController {
	@objc private func shuffleBtnTapped() {
		viewModel.toggleShuffleMode()
	}

	@objc private func replayBtnTapped() {
		viewModel.toggleReplayMode()
	}

	@objc private func playBtnTapped() {
		self.openMainPlayer(indexPath: IndexPath(row: 0, section: 0))
	}

	private func bindViewModel() {
		viewModel.onDeleteMusic = { [weak self] in
			guard let self = self else { return }
			let playlist = self.viewModel.getRealPlaylist()
			self.delegate?.playlistDidChange(self, playlist: playlist)
			self.musicTbv.reloadData()
		}

		viewModel.onRenameMusic = { [weak self] indexPath in
			self?.musicTbv.reloadRows(at: [indexPath], with: .automatic)
		}

		viewModel.onToggleShuffle = { [weak self] in
			guard let self = self else { return }
			self.shuffleBtn.setImage(UIImage(named: self.viewModel.shuffleBtnImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
			self.musicTbv.reloadData()
		}

		viewModel.onToggleReplay = { [weak self] in
			guard let self = self else { return }
			self.replayModeBtn.setImage(UIImage(named: self.viewModel.replayBtnImage)?.withRenderingMode(.alwaysOriginal), for: .normal)
		}
	}

	private func openMainPlayer(indexPath: IndexPath) {
		let music = viewModel.getMusicModel(at: indexPath)
		let playlist = viewModel.getPlaylistForPlay()
		let replayMode = viewModel.replayMode
		self.playMusic(playlist: playlist, currentMusic: music, replayMode: replayMode)
		self.navigationController?.popToRootViewController(animated: true)
	}
}

// MARK: - UITableViewDelegate
extension PlaylistDetailController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		tableView.backgroundView = (viewModel.numberOfItems == 0) ? noDataView : nil
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistDetailTBCell.cellId,
												 for: indexPath) as! PlaylistDetailTBCell
		cell.delegate = self
		let music = viewModel.getMusicModel(at: indexPath)
		cell.viewModel = PlaylistDetailCellViewModel(music: music, indexPath: indexPath)
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

// MARK: - CreatePlaylistViewDelegate
extension PlaylistDetailController: CreatePlaylistViewDelegate {
	func didTapOkButton(with name: String, option: CreatePlaylistView.Option) {
		if name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			self.view.displayToast("Name is invalid")
			return
		}

		if option == .rename {
			guard let indexPath = lastSelectedIndexPath else { return }
			let success = viewModel.renameMusic(at: indexPath, name: name)
			let msg = success ? "Rename song successfully" : "Rename song failed"
			self.view.displayToast(msg)
		}
	}
}

// MARK: - PlaylistDetailTBCellDelegate
extension PlaylistDetailController: PlaylistDetailTBCellDelegate {
	func didSelectMore(_ cell: PlaylistDetailTBCell) {
		guard let cellVM = cell.viewModel else { return }
		lastSelectedIndexPath = musicTbv.indexPath(for: cell)

		let vc = PLaylistDetailSheetController(music: cellVM.music)
		vc.delegate = self
		vc.modalPresentationStyle = .overFullScreen
		self.present(vc, animated: false) {
			vc.showSheet()
		}
	}
}

// MARK: - PLaylistDetailSheetDelegate
extension PlaylistDetailController: PLaylistDetailSheetDelegate {
	func didTapRename(_ controller: PLaylistDetailSheetController, music: MusicModel) {
		self.createPlaylistView.show()
	}

	func didTapShare(_ controller: PLaylistDetailSheetController, music: MusicModel) {
		let urlShare = music.sourceType == .online ? music.remotePath : music.absolutePath
		let objectsToShare: [Any] = [urlShare as Any]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		if let indexPath = self.lastSelectedIndexPath, let cell = self.musicTbv.cellForRow(at: indexPath) {
			activityVC.popoverPresentationController?.sourceView = cell
		}
		self.present(activityVC, animated: true, completion: nil)
	}

	func didTapDelete(_ controller: PLaylistDetailSheetController, music: MusicModel) {
		let alert = UIAlertController(title: "Delete song",
									  message: "Are you sure you want to delete?",
									  preferredStyle: .alert)

		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
			guard let self = self, let indexPath = self.lastSelectedIndexPath else { return }
			let success = self.viewModel.deleteMusic(at: indexPath)
			let msg = success ? "Delete song successful" : "Failed to delete song"
			self.view.displayToast(msg)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

		alert.addAction(deleteAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true)
	}
}
