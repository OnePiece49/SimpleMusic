//
//  HomeTopicTBVCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 31/08/2023.
//

import UIKit

fileprivate let columns: CGFloat = UIDevice.current.is_iPhone ? 3 : 5
fileprivate let spacing: CGFloat = UIDevice.current.is_iPhone ? 16 : 24
fileprivate let padding: CGFloat = UIDevice.current.is_iPhone ? 24 : 24

protocol HomeTopicTBVCellDelegate: AnyObject {
	func didTapViewAll(_ cell: HomeTopicTBVCell)
	func didTapOpenGenre(_ cell: HomeTopicTBVCell, genre: YTGenresModel)
}

class HomeTopicTBVCell: BaseTableViewCell {
	
	static var cellHeight: CGFloat {
		return navBarHeight + 16 // spacing between header - topicClv
			+ (HomeTopicCLCell.cellHeight*2 + spacing*2) // topicClv has 2 rows
	}
	private static let navBarHeight: CGFloat = 44

	// MARK: - Properties
	var genres: [YTGenresModel] = [] {
		didSet {
			topicClv.reloadData()
		}
	}

	private lazy var colors: [UIColor] = {
		return Array.generateRandomColors(count: genres.count)
	}()

	private let maximumDisplayItem: Int = 6
	weak var delegate: HomeTopicTBVCellDelegate?

	// MARK: - UI components
	private var navBar: NavigationCustomView!

	private lazy var topicClv: UICollectionView = {
		let clv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		clv.translatesAutoresizingMaskIntoConstraints = false
		clv.backgroundColor = .clear
		clv.isScrollEnabled = false
		clv.delegate = self
		clv.dataSource = self
		clv.register(HomeTopicCLCell.self, forCellWithReuseIdentifier: HomeTopicCLCell.cellId)
		return clv
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
		let firstAttributeLeft = AttibutesButton(tilte: "Topic",
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
		contentView.addSubview(topicClv)

		NSLayoutConstraint.activate([
			navBar.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			navBar.topAnchor.constraint(equalTo: contentView.topAnchor),
			navBar.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			navBar.heightAnchor.constraint(equalToConstant: 44),

			topicClv.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			topicClv.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 16),
			topicClv.rightAnchor.constraint(equalTo: contentView.rightAnchor),
			topicClv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
		])
	}
}

// MARK: - UICollectionViewDataSource
extension HomeTopicTBVCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return (genres.count < maximumDisplayItem) ? genres.count : maximumDisplayItem
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTopicCLCell.cellId,
													  for: indexPath) as! HomeTopicCLCell
		cell.genre = genres[indexPath.item]
		cell.posterColor = colors[indexPath.item]
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.didTapOpenGenre(self, genre: genres[indexPath.item])
	}
}

// MARK: - UICollectionViewDelegate
extension HomeTopicTBVCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return spacing / 2
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return spacing
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (collectionView.frame.width - padding * 2 - ((columns - 1) * spacing)) / columns
		return CGSize(width: width, height: HomeTopicCLCell.cellHeight)
	}
}

