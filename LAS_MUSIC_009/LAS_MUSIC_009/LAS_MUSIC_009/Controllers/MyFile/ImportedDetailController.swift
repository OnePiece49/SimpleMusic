//
//  DownloadedController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 15/08/2023.
//

import UIKit

class ImportedDetailController: MyFileBaseController {
	
	private let viewModel = ImportedDetailViewModel()
	private var lastSelectedIndexPath: IndexPath?
	private let noDataView = NoDataView()
	
	// MARK: - Life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTBView()
		bindViewModel()
		loadAllMusics()
	}
	
	private func setupTBView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(ImportedDetailTBCell.self, forCellReuseIdentifier: ImportedDetailTBCell.cellId)
	}
	
	private func bindViewModel() {
		viewModel.onDeleteMusic = { [weak self] indexPath in
			self?.tableView.deleteRows(at: [indexPath], with: .left)
		}
	}
	
	private func loadAllMusics() {
		viewModel.loadAllMusics()
	}
}

// MARK: - UITableViewDelegate
extension ImportedDetailController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		tableView.backgroundView = (viewModel.numberOfItems == 0) ? noDataView : nil
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ImportedDetailTBCell.cellId,
												 for: indexPath) as! ImportedDetailTBCell
		cell.music = viewModel.getMusicModel(at: indexPath)
		cell.delegate = self
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let music = viewModel.getMusicModel(at: indexPath)
		guard let playlist = viewModel.playlist else {return}
		
		self.navigationController?.popToRootViewController(animated: true)
		self.playMusic(playlist: playlist, currentMusic: music)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return ImportedDetailTBCell.cellHeight
	}
}

// MARK: - ImportedDetailTBCellDelegate
extension ImportedDetailController: ImportedDetailTBCellDelegate {
	func didSelectMore(_ cell: ImportedDetailTBCell) {
		guard let music = cell.music else { return }
		lastSelectedIndexPath = tableView.indexPath(for: cell)
		
		let vc = ImportedDetailSheetController(music: music)
		vc.delegate = self
		vc.modalPresentationStyle = .overFullScreen
		self.present(vc, animated: false) {
			vc.showSheet()
		}
	}
}

// MARK: - ImportedDetailSheetDelegate
extension ImportedDetailController: ImportedDetailSheetDelegate {
	func didTapAddToPlaylist(_ controller: ImportedDetailSheetController, music: MusicModel) {
		let vc = AddToPlaylistController(music: music)
		self.present(vc, animated: true)
	}
	
	func didTapShare(_ controller: ImportedDetailSheetController, music: MusicModel) {
		let objectsToShare: [Any] = [music.absolutePath as Any]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		activityVC.popoverPresentationController?.sourceView = self.view
		self.present(activityVC, animated: true, completion: nil)
	}
	
	func didTapDelete(_ controller: ImportedDetailSheetController, music: MusicModel) {
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
