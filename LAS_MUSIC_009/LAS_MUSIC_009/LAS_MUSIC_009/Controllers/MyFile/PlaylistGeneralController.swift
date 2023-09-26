//
//  PlaylistGeneralController.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 16/08/2023.
//

import UIKit

class PlaylistGeneralController: MyFileBaseController {

	private let viewModel = PlaylistGeneralViewModel()
	private let noDataView = NoDataView()
	private var lastSelectedIndexPath: IndexPath?
	private var indexPathToReload: IndexPath?

	// MARK: - UI components
	private let createPlaylistView = CreatePlaylistView()

	private lazy var createPlaylistBtn: UIButton = {
		let btn = UIButton(type: .system)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.setTitle("Add New Playlist", for: .normal)
		btn.setTitleColor(UIColor(rgb: 0x20242F), for: .normal)
		btn.backgroundColor = .secondaryYellow
		btn.titleLabel?.font = .fontRailwayBold(16)
		btn.layer.cornerRadius = isIphone ? 4 : 8
		btn.addTarget(self, action: #selector(createNewPlaylist), for: .touchUpInside)
		return btn
	}()

	// MARK: - Life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTBView()
		bindViewModel()
		createPlaylistView.delegate = self
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let indexPath = indexPathToReload {
			self.tableView.reloadRows(at: [indexPath], with: .none)
			self.indexPathToReload = nil
		}
	}

	private func setupTBView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(PlaylistGeneralTBCell.self, forCellReuseIdentifier: PlaylistGeneralTBCell.cellId)
	}

	override func setupConstraints() {
		view.addSubview(createPlaylistBtn)
		view.addSubview(createPlaylistView)

		navBar.anchor(leading: view.leadingAnchor,
					  top: view.safeAreaLayoutGuide.topAnchor,
					  trailing: view.trailingAnchor, height: 44)

		createPlaylistBtn.anchor(leading: view.leadingAnchor, paddingLeading: isIphone ? 20 : 40,
								 top: navBar.bottomAnchor, paddingTop: 12,
								 trailing: view.trailingAnchor, paddingTrailing: isIphone ? -20 : -40,
								 height: isIphone ? 40 : 60)

		tableView.anchor(leading: view.leadingAnchor,
						 top: createPlaylistBtn.bottomAnchor, paddingTop: 12,
						 trailing: view.trailingAnchor,
						 bottom: view.bottomAnchor)

		createPlaylistView.pinToView(view)
	}

}

// MARK: - Method
extension PlaylistGeneralController {
	@objc private func createNewPlaylist() {
		createPlaylistView.option = .create
		createPlaylistView.show()
	}

	private func bindViewModel() {
		viewModel.onCreatePlaylist = { [weak self] indexPath in
			self?.tableView.insertRows(at: [indexPath], with: .left)
		}

		viewModel.onRenamePlaylist = { [weak self] indexPath in
			self?.tableView.reloadRows(at: [indexPath], with: .automatic)
		}

		viewModel.onDeletePlaylist = { [weak self] indexPath in
			self?.tableView.deleteRows(at: [indexPath], with: .left)
		}

		viewModel.loadAllPlaylists()
	}
}

// MARK: - UITalbeViewDelegate
extension PlaylistGeneralController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		tableView.backgroundView = (viewModel.numberOfItems == 0) ? noDataView : nil
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistGeneralTBCell.cellId,
												 for: indexPath) as! PlaylistGeneralTBCell
		cell.delegate = self
		cell.playlist = viewModel.getPlaylist(at: indexPath)
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let playlist = viewModel.getPlaylist(at: indexPath)
		let detailVM = PlaylistDetailViewModel(playlist: playlist)
		let vc = PlaylistDetailController(viewModel: detailVM)
		vc.delegate = self
		self.navigationController?.pushViewController(vc, animated: true)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return PlaylistGeneralTBCell.cellHeight
	}
}

// MARK: - PlaylistDetailControllerDelegate
extension PlaylistGeneralController: PlaylistDetailControllerDelegate {
	func playlistDidChange(_ controller: PlaylistDetailController, playlist: PlaylistModel) {
		guard let index = viewModel.getIndexForPlaylist(playlist) else { return }
		self.indexPathToReload = IndexPath(row: index, section: 0)
	}
}

// MARK: - PlaylistGeneralTBCellDelegate
extension PlaylistGeneralController: PlaylistGeneralTBCellDelegate {
	func didSelectMore(_ cell: PlaylistGeneralTBCell) {
		guard let playlist = cell.playlist else { return }
		self.lastSelectedIndexPath = tableView.indexPath(for: cell)

		let vc = PlaylistGeneralSheetController(playlist: playlist)
		vc.delegate = self
		vc.modalPresentationStyle = .overFullScreen
		self.present(vc, animated: false) {
			vc.showSheet()
		}
	}
}

// MARK: - CreatePlaylistViewDelegate
extension PlaylistGeneralController: CreatePlaylistViewDelegate {
	func didTapOkButton(with name: String, option: CreatePlaylistView.Option) {
		if name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			self.view.displayToast("Name is invalid")
			return
		}

		if option == .create {
			let success = viewModel.createNewPlaylist(name: name)
			let msg = success ? "Create playlist successfully" : "Create playlist failed"
			self.view.displayToast(msg)

		} else if option == .rename {
			guard let indexPath = lastSelectedIndexPath else { return }
			let success = viewModel.renamePlaylist(at: indexPath, name: name)
			let msg = success ? "Rename playlist successfully" : "Rename playlist failed"
			self.view.displayToast(msg)
		}
	}
}

// MARK: - PlaylistGeneralSheetDelegate
extension PlaylistGeneralController: PlaylistGeneralSheetDelegate {
	func didTapRename(_ controller: PlaylistGeneralSheetController, playlist: PlaylistModel) {
		self.createPlaylistView.option = .rename
		self.createPlaylistView.show()
	}

	func didTapDelete(_ controller: PlaylistGeneralSheetController, playlist: PlaylistModel) {
		let alert = UIAlertController(title: "Delete playlist",
									  message: "Are you sure you want to delete?",
									  preferredStyle: .alert)

		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
			guard let self = self, let indexPath = self.lastSelectedIndexPath else { return }
			let success = self.viewModel.deletePlaylist(at: indexPath)
			let msg = success ? "Delete song successful" : "Failed to delete song"
			self.view.displayToast(msg)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

		alert.addAction(deleteAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true)
	}
}
