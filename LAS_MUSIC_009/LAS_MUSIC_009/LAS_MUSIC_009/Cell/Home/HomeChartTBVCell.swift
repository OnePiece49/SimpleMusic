//
//  HomeChartTBVCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 31/08/2023.
//

import UIKit

protocol HomeChartTBVCellDelegate: AnyObject {
	func didTapViewAll(_ cell: HomeChartTBVCell)
	func didSelectMore(_ cell: HomeChartTBVCell, music: MusicModel)
	func didTapPlayMusic(_ cell: HomeChartTBVCell, music: MusicModel)
}

class HomeChartTBVCell: BaseTableViewCell {

	static var cellHeight: CGFloat {
		return MusicChartDetailTBCell.cellHeight * 5 // maximum display cells
			+ HomeChartTBVCell.navBarHeight + 16 // spacing between header - musicTbv
	}
	private static let navBarHeight: CGFloat = 44

	// MARK: - Properties
	var musics: [MusicModel] = [] {
		didSet {
			musicTbv.reloadData()
		}
	}
	weak var delegate: HomeChartTBVCellDelegate?
	private let maximumDisplayCell: Int = 5

	// MARK: - UI components
	private var navBar: NavigationCustomView!

	private let musicTbv: UITableView = {
		let tbv = UITableView(frame: .zero, style: .plain)
		tbv.translatesAutoresizingMaskIntoConstraints = false
		tbv.backgroundColor = UIColor(rgb: 0x33313F)
		tbv.isScrollEnabled = false
		tbv.roundCorners(radius: 10)
		return tbv
	}()

	// MARK: - Lifecycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupNavBar()
		setupTBView()
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupNavBar() {
		let firstAttributeLeft = AttibutesButton(tilte: "Music Chart",
												 font: UIFont.fontRailwayBold(24),
												 titleColor: UIColor(rgb: 0xEEEEEE))

		let attributeRight = AttibutesButton(tilte: "View all",
											 font: UIFont.fontRailwayBold(12),
											 titleColor: UIColor(rgb: 0xEEEEEE)) { [weak self] in
			guard let self = self else { return }
			self.delegate?.didTapViewAll(self)
		}

		self.navBar = NavigationCustomView(centerTitle: "",
										   attributeLeftButtons: [firstAttributeLeft],
										   attributeRightBarButtons: [attributeRight],
										   isHiddenDivider: true,
										   beginSpaceLeftButton: 24,
										   beginSpaceRightButton: 22)
		navBar.translatesAutoresizingMaskIntoConstraints = false
	}

	private func setupTBView() {
		musicTbv.delegate = self
		musicTbv.dataSource = self
		musicTbv.register(MusicChartDetailTBCell.self, forCellReuseIdentifier: MusicChartDetailTBCell.cellId)
	}

	private func setupConstraints() {
		contentView.addSubview(navBar)
		contentView.addSubview(musicTbv)

		NSLayoutConstraint.activate([
			navBar.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			navBar.topAnchor.constraint(equalTo: contentView.topAnchor),
			navBar.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			navBar.heightAnchor.constraint(equalToConstant: HomeChartTBVCell.navBarHeight),

			musicTbv.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 24),
			musicTbv.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 16),
			musicTbv.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -24),
			musicTbv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
		])
	}
}

// MARK: - UITableViewDataSource
extension HomeChartTBVCell: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (musics.count < maximumDisplayCell) ? musics.count : maximumDisplayCell
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: MusicChartDetailTBCell.cellId,
												 for: indexPath) as! MusicChartDetailTBCell
		let cellVM = PlaylistDetailCellViewModel(music: musics[indexPath.row], indexPath: indexPath)
		cell.viewModel = cellVM

		cell.onSelectMore = { [weak self] _, music in
			guard let self = self else { return }
			self.delegate?.didSelectMore(self, music: music)
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		delegate?.didTapPlayMusic(self, music: musics[indexPath.row])
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return MusicChartDetailTBCell.cellHeight
	}
}
