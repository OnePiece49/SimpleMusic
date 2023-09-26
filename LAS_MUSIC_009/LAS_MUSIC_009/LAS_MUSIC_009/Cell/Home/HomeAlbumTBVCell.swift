//
//  HomeAlbumTBVCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 31/08/2023.
//

import UIKit

protocol HomeAlbumTBVCellDelegate: AnyObject {
	func didSelectViewAllButton()
	func didSelectHomeAlbumsCell(album: YTAblumModel)
}

class HomeAlbumTBVCell: BaseTableViewCell {

	static var cellHeight: CGFloat {
		return 70 + // nav bar height + spacing
			(UIScreen.main.bounds.width - 40) / 1.6 // scale factor
	}

	//MARK: - Properties
	var albums: [YTAblumModel] = [] {
		didSet {
			pagerView.reloadData()
			loadingIndicator.stopAnimating()
		}
	}
 	weak var delegate: HomeAlbumTBVCellDelegate?
	private let scaleFactor: CGFloat = 1.6

	// MARK: - UI components
	private var navBar: NavigationCustomView!
	private let loadingIndicator = UIActivityIndicatorView(style: .white)

	private lazy var pagerView: FSPagerView = {
		let view = FSPagerView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.dataSource = self
		view.delegate = self
		view.register(FSPagerViewCell.self, forCellWithReuseIdentifier: FSPagerViewCell.cellId)
		return view
	}()

	//MARK: - View Lifecycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureNavBar()
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	//MARK: - Helpers
	open override func layoutSubviews() {
		super.layoutSubviews()

		pagerView.itemSize = CGSize(width: (frame.width - 20) / scaleFactor , height: (frame.width - 20) / scaleFactor)
		pagerView.automaticSlidingInterval = 3
		pagerView.isInfinite = false
		pagerView.decelerationDistance = 2
		pagerView.scrollBack = Int(frame.width / (scaleFactor*2))
		pagerView.transformer = FSPagerViewTransformer(type: .linear)
		pagerView.backgroundColor = UIColor(rgb: 0x1C1B1F)
	}

	private func setupConstraints() {
		contentView.addSubview(navBar)
		contentView.addSubview(pagerView)
		contentView.addSubview(loadingIndicator)

		NSLayoutConstraint.activate([
			navBar.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			navBar.topAnchor.constraint(equalTo: contentView.topAnchor),
			navBar.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			navBar.heightAnchor.constraint(equalToConstant: 44),

			pagerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			pagerView.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 16),
			pagerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			pagerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

			loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
		loadingIndicator.setDimensions(width: 35, height: 35)
		loadingIndicator.startAnimating()

		layoutIfNeeded()
	}

	private func configureNavBar() {
		let firstAttributeLeft = AttibutesButton(tilte: "New Albums",
												 font: UIFont.fontRailwayBold(24),
												 titleColor: UIColor(rgb: 0xEEEEEE))

		let attributeRight = AttibutesButton(tilte: "View all",
											 font: UIFont.fontRailwayBold(12),
											 titleColor: UIColor(rgb: 0xEEEEEE)) { [weak self] in
			self?.delegate?.didSelectViewAllButton()
		}

		self.navBar = NavigationCustomView(centerTitle: "",
										   attributeLeftButtons: [firstAttributeLeft],
										   attributeRightBarButtons: [attributeRight],
										   isHiddenDivider: true,
										   beginSpaceLeftButton: 24,
										   beginSpaceRightButton: 22)
		navBar.translatesAutoresizingMaskIntoConstraints = false
	}

}

//MARK: - delegate
extension HomeAlbumTBVCell: FSPagerViewDataSource, FSPagerViewDelegate {
	func numberOfItems(in pagerView: FSPagerView) -> Int {
		return albums.count
	}

	func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
		let cell = pagerView.dequeueReusableCell(withReuseIdentifier: FSPagerViewCell.cellId, at: index)
		cell.album = albums[index]
		return cell
	}

	func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) { }

	func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) { }

	func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
		self.delegate?.didSelectHomeAlbumsCell(album: albums[index])
	}
}

