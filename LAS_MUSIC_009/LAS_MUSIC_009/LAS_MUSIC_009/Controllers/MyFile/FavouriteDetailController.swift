//
//  FavouriteDetailController.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 18/08/2023.
//

import UIKit

class FavouriteDetailController: MyFileBaseController {

	private let viewModel = FavouriteDetailViewModel()
	private let noDataView = NoDataView()

    override func viewDidLoad() {
        super.viewDidLoad()
		setupTBView()
		bindViewModel()
		loadAllMusics()
    }

	private func setupTBView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(FavouriteDetailTBCell.self, forCellReuseIdentifier: FavouriteDetailTBCell.cellId)
	}

	private func bindViewModel() {
		viewModel.onUnFavouriteMusic = { [weak self] indexPath in
			self?.tableView.deleteRows(at: [indexPath], with: .left)
		}
	}

	private func loadAllMusics() {
		viewModel.loadAllMusics()
	}

}

// MARK: - UITableViewDelegate
extension FavouriteDetailController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		tableView.backgroundView = (viewModel.numberOfItems == 0) ? noDataView : nil
		return 1
	}
    
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItems
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteDetailTBCell.cellId,
												 for: indexPath) as! FavouriteDetailTBCell
		cell.music = viewModel.getMusicModel(at: indexPath)
		cell.delegate = self
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

        let music = viewModel.getMusicModel(at: indexPath)
        guard let playlist = viewModel.favouritePlaylist else {return}
        self.playMusic(playlist: playlist, currentMusic: music)
        self.navigationController?.popToRootViewController(animated: true)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return FavouriteDetailTBCell.cellHeight
	}
}

// MARK: - FavouriteDetailTBCellDelegate
extension FavouriteDetailController: FavouriteDetailTBCellDelegate {
	func didTapUnfavourite(_ cell: FavouriteDetailTBCell) {
		guard let indexPath = tableView.indexPath(for: cell) else { return }
		let success = viewModel.unFavouriteMusic(at: indexPath)
		let msg = success ? "Successfully unfavourite song" : "Failed to unfavourite song"
		view.displayToast(msg)
	}
}
