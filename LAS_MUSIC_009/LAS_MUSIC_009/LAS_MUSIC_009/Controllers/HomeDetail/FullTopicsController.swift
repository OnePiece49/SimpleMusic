//
//  FullTopicsController.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 29/08/2023.
//

import UIKit

fileprivate let columns: CGFloat = UIDevice.current.is_iPhone ? 2 : 4
fileprivate let spacing: CGFloat = UIDevice.current.is_iPhone ? 16 : 24
fileprivate let padding: CGFloat = UIDevice.current.is_iPhone ? 16 : 24

class FullTopicsController: BaseController {

	// MARK: - Properties
	let viewModel: FullTopicsViewModel

	private lazy var colors: [UIColor] = {
		return Array.generateRandomColors(count: viewModel.numberOfItems)
	}()

	// MARK: - UI components
	private var navBar: NavigationCustomView!

	private lazy var topicClv: UICollectionView = {
		let clv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		clv.translatesAutoresizingMaskIntoConstraints = false
		clv.backgroundColor = .clear
		clv.delegate = self
		clv.dataSource = self
		clv.register(HomeTopicCLCell.self, forCellWithReuseIdentifier: HomeTopicCLCell.cellId)
		return clv
	}()

	// MARK: - Life cycle
	init(viewModel: FullTopicsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setupNavBar()
		setupConstraints()
    }
    
	private func setupNavBar() {
		let firstAttributeLeft = AttibutesButton(image: UIImage(named: AssetConstant.ic_back)?.withRenderingMode(.alwaysOriginal),
												 sizeImage: CGSize(width: 24, height: 25)) { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		self.navBar = NavigationCustomView(centerTitle: "Topic",
										   centerColor: .white,
										   attributeLeftButtons: [firstAttributeLeft],
										   attributeRightBarButtons: [],
										   isHiddenDivider: true,
										   beginSpaceLeftButton: 24)
		navBar.translatesAutoresizingMaskIntoConstraints = false
	}

	private func setupConstraints() {
		view.addSubview(navBar)
		view.addSubview(topicClv)

		NSLayoutConstraint.activate([
			navBar.leftAnchor.constraint(equalTo: view.leftAnchor),
			navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			navBar.rightAnchor.constraint(equalTo: view.rightAnchor),
			navBar.heightAnchor.constraint(equalToConstant: 44),

			topicClv.leftAnchor.constraint(equalTo: view.leftAnchor),
			topicClv.topAnchor.constraint(equalTo: navBar.bottomAnchor),
			topicClv.rightAnchor.constraint(equalTo: view.rightAnchor),
			topicClv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}
}

// MARK: - UICollectionViewDataSource
extension FullTopicsController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel.numberOfItems
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeTopicCLCell.cellId,
													  for: indexPath) as! HomeTopicCLCell
		cell.genre = viewModel.getGenreModel(at: indexPath)
		cell.posterColor = colors[indexPath.item]
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let genre = viewModel.getGenreModel(at: indexPath)
		let vc = HomeDetailBaseController(title: genre.title)
		viewModel.getGenrePLaylistDetail(at: indexPath) { musics in
			vc.viewModel = HomeDetailViewModel(musics: musics)
		}
		self.navigationController?.pushViewController(vc, animated: true)
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FullTopicsController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return padding / 2
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return padding
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = (collectionView.frame.width - spacing * 2 - ((columns - 1) * padding)) / columns
		return CGSize(width: width, height: HomeTopicCLCell.cellHeight + 30)
	}
}
