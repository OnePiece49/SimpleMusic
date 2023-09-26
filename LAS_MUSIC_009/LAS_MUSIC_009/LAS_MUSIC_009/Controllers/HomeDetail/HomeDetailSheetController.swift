//
//  HomeDetailSheetController.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 30/08/2023.
//

import UIKit

protocol HomeDetailSheetControllerDelegate: AnyObject {
	func didTapAddToPlaylist(_ controller: HomeDetailSheetController, music: MusicModel)
	func didTapShare(_ controller: HomeDetailSheetController, music: MusicModel)
}

class HomeDetailSheetController: TransparentBottomSheetController {

	// MARK: - Properties
	private let music: MusicModel
	private let actions: [SheetAction] = [.addToPlaylist, .share]
	weak var delegate: HomeDetailSheetControllerDelegate?

	// MARK: - UI components
	override var rootView: UIView {
		return containerView
	}

	override var sheetHeight: BottomSheetHeight {
		return .aspect(190/813)
	}

	private let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}()

	private let titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 2
		label.font = .fontRailwayBold(18)
		label.textColor = UIColor(rgb: 0xEEEEEE)
		label.textAlignment = .center
		return label
	}()

	private let tableView: UITableView = {
		let tbv = UITableView(frame: .zero, style: .plain)
		tbv.translatesAutoresizingMaskIntoConstraints = false
		tbv.backgroundColor = .clear
		tbv.isScrollEnabled = false
		tbv.separatorStyle = .none
		return tbv
	}()

	// MARK: - Life cycle
	init(music: MusicModel) {
		self.music = music
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupTBView()
		titleLbl.text = music.name
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.containerView.applyGradient(colours: [UIColor(rgb: 0x717171).withAlphaComponent(0.8),
												   UIColor(rgb: 0x545454).withAlphaComponent(0.8)])
	}

	private func setupTBView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(ImportedSheetTBCell.self, forCellReuseIdentifier: ImportedSheetTBCell.cellId)
	}

	override func setupConstraints() {
		super.setupConstraints()
		containerView.addSubview(titleLbl)
		containerView.addSubview(tableView)

		titleLbl.anchor(leading: containerView.leadingAnchor, paddingLeading: 20,
						top: containerView.topAnchor, paddingTop: 20,
						trailing: containerView.trailingAnchor, paddingTrailing: -20)

		tableView.anchor(leading: titleLbl.leadingAnchor,
						 top: titleLbl.bottomAnchor, paddingTop: 12,
						 trailing: titleLbl.trailingAnchor,
						 bottom: containerView.bottomAnchor)
	}
    
}

// MARK: - UITableViewDelegate
extension HomeDetailSheetController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return actions.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ImportedSheetTBCell.cellId,
												 for: indexPath) as! ImportedSheetTBCell
		let action = actions[indexPath.row]
		cell.setTitle(action.title)
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let action = actions[indexPath.row]

		self.removeSheet {
			switch action {
				case .addToPlaylist:
					self.delegate?.didTapAddToPlaylist(self, music: self.music)
				case .share:
					self.delegate?.didTapShare(self, music: self.music)
				default:
					break
			}
		}
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return ImportedSheetTBCell.cellHeight
	}
}
