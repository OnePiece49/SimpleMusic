//
//  HomeTrendingTBVCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 31/08/2023.
//

import UIKit

protocol HomeTrendingTBVCellDelegate: AnyObject {
	func didTapViewAll(_ cell: HomeTrendingTBVCell)
	func didTapPlayMusic(_ cell: HomeTrendingTBVCell, music: MusicModel)
	func didTapFavoriteMusic(_ cell: HomeTrendingTBVCell, music: MusicModel)
}

class HomeTrendingTBVCell: BaseTableViewCell {

	static let cellHeight: CGFloat = 280

	// MARK: - Properties
	var musics: [MusicModel] = [] {
		didSet {
			updateUI()
		}
	}
	weak var delegate: HomeTrendingTBVCellDelegate?
	private let maximumDisplayPage: Int = 6
	private let columns: CGFloat = UIDevice.current.is_iPhone ? 1 : 2
	private let spacing: CGFloat = UIDevice.current.is_iPhone ? 0 : 24

	// MARK: - UI components
	private var navBar: NavigationCustomView!

	private lazy var trendingClv: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		let clv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		clv.translatesAutoresizingMaskIntoConstraints = false
		clv.backgroundColor = .clear
		clv.isPagingEnabled = UIDevice.current.is_iPhone
		clv.layer.cornerRadius = 8
		clv.layer.masksToBounds = true
		clv.showsHorizontalScrollIndicator = false
		clv.delegate = self
		clv.dataSource = self
		clv.register(HomeTrendingCLCell.self, forCellWithReuseIdentifier: HomeTrendingCLCell.cellId)
		return clv
	}()

	private let pageControl: UIPageControl = {
		let control = UIPageControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.pageIndicatorTintColor = UIColor(rgb: 0x71737B)
		control.currentPageIndicatorTintColor = .white
		return control
	}()

	// MARK: - Init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupNavBar()
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupNavBar() {
		let firstAttributeLeft = AttibutesButton(tilte: "Top Trending",
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

	private func setupConstraints() {
		contentView.addSubview(navBar)
		contentView.addSubview(trendingClv)
		contentView.addSubview(pageControl)

		NSLayoutConstraint.activate([
			navBar.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			navBar.topAnchor.constraint(equalTo: contentView.topAnchor),
			navBar.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			navBar.heightAnchor.constraint(equalToConstant: 44),

			trendingClv.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 24),
			trendingClv.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 16),
			trendingClv.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -24),
			trendingClv.heightAnchor.constraint(equalToConstant: 200),

			pageControl.topAnchor.constraint(equalTo: trendingClv.bottomAnchor, constant: 12),
			pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
			pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
		])
	}

}

// MARK: - Methods
extension HomeTrendingTBVCell {
	func updateFavoriteMusic(_ music: MusicModel) {
		if let index = musics.firstIndex(of: music) {
			trendingClv.reloadItems(at: [IndexPath(item: index, section: 0)])
		}
	}

	private func updateUI() {
		pageControl.numberOfPages = (musics.count < maximumDisplayPage) ? musics.count/Int(columns) : maximumDisplayPage/Int(columns)
		pageControl.currentPage = 0
		trendingClv.reloadData()
	}

	private func didTapFavorite(cell: HomeTrendingCLCell) {
		guard let indexPath = trendingClv.indexPath(for: cell) else { return }
		let music = musics[indexPath.item]

		if music.isFavorited {
			_ = RealmService.shared.removeFromFavourite(music: music)
		} else {
			_ = RealmService.shared.saveToFavourite(music: music)
		}

		trendingClv.reloadItems(at: [indexPath])
		delegate?.didTapFavoriteMusic(self, music: music)
	}
}

// MARK: - UICollectionViewDataSource
extension HomeTrendingTBVCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return (musics.count < maximumDisplayPage) ? musics.count : maximumDisplayPage
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTrendingCLCell.cellId,
													  for: indexPath) as! HomeTrendingCLCell
		cell.viewModel = HomeTrendingCLCellViewModel(music: musics[indexPath.item])

		cell.onTapFavorite = { [weak self] selectedCell in
			self?.didTapFavorite(cell: selectedCell)
		}
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.didTapPlayMusic(self, music: musics[indexPath.item])
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let currentOffset = scrollView.contentOffset.x
		let pageWidth = scrollView.frame.width
		let currentPage = round(currentOffset / pageWidth)
		self.pageControl.currentPage = Int(currentPage)
	}
}

// MARK: - UICollectionViewDelegate
extension HomeTrendingTBVCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return .zero
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return spacing
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return spacing
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (collectionView.frame.width - ((columns - 1) * spacing)) / columns
		return CGSize(width: width, height: collectionView.frame.height)
	}
}

