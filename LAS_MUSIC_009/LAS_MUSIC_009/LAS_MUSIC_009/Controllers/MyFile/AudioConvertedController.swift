//
//  AudioConvertedController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 17/08/2023.
//

import UIKit

class AudioConvertedController: MyFileBaseController {

    private let viewModel = AudioConvertedViewModel()
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
        tableView.register(AudioConvertedTBCell.self, forCellReuseIdentifier: AudioConvertedTBCell.cellId)
    }

    private func bindViewModel() {
        viewModel.onDeleteMusic = { [weak self] index in
            let indexPath = IndexPath(row: index, section: 0)
            self?.tableView.deleteRows(at: [indexPath], with: .left)
        }
    }

    private func loadAllMusics() {
        viewModel.loadAllMusics()
    }
}

// MARK: - UITableViewDelegate
extension AudioConvertedController: UITableViewDataSource, UITableViewDelegate {
	func numberOfSections(in tableView: UITableView) -> Int {
		tableView.backgroundView = (viewModel.numberOfItems == 0) ? noDataView : nil
		return 1
	}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AudioConvertedTBCell.cellId,
                                                 for: indexPath) as! AudioConvertedTBCell
        cell.music = viewModel.getMusicModel(at: indexPath)

        cell.onSelectMoreBtn = { [weak self] selectedCell in
            guard let indexPath = self?.tableView.indexPath(for: selectedCell) else { return }
            self?.handleSelectMore(indexPath: indexPath)
        }
        return cell
    }

    private func handleSelectMore(indexPath: IndexPath) {
        let music = viewModel.getMusicModel(at: indexPath)
        let vc = ImportedDetailSheetController(music: music)
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false) {
            vc.showSheet()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = viewModel.getMusicModel(at: indexPath)
        guard let playlist = viewModel.playlist else {return}
        
        self.navigationController?.popToRootViewController(animated: true)
		self.playMusic(playlist: playlist, currentMusic: music)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return AudioConvertedTBCell.cellHeight
	}
}

// MARK: - ImportedDetailSheetDelegate
extension AudioConvertedController: ImportedDetailSheetDelegate {
    func didTapAddToPlaylist(_ controller: ImportedDetailSheetController, music: MusicModel) {
        controller.removeSheet {
			let vc = AddToPlaylistController(music: music)
			self.present(vc, animated: true)
        }
    }

    func didTapShare(_ controller: ImportedDetailSheetController, music: MusicModel) {
        controller.removeSheet {
            let objectsToShare: [Any] = [music.absolutePath as Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    func didTapDelete(_ controller: ImportedDetailSheetController, music: MusicModel) {
        controller.removeSheet {
            let alert = UIAlertController(title: "Delete song",
                                          message: "Are you sure you want to delete?",
                                          preferredStyle: .alert)

            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                let success = self.viewModel.deleteMusic(music)
                let msg = success ? "Delete song successful" : "Failed to delete song"
                self.view.displayToast(msg)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
    }
}
