//
//  HomeTopicCLCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 29/08/2023.
//

import UIKit

class HomeTopicCLCell: BaseCollectionViewCell {

	static let cellHeight: CGFloat = 66

	var genre: YTGenresModel? {
		didSet {
			titleLbl.text = genre?.title
		}
	}

	var posterColor: UIColor? {
		didSet {
			posterView.backgroundColor = posterColor
		}
	}

	private let posterView: UIImageView = {
		let imv = UIImageView()
		imv.translatesAutoresizingMaskIntoConstraints = false
		imv.contentMode = .scaleAspectFill
		imv.backgroundColor = .purple
		return imv
	}()

	private let titleLbl: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.numberOfLines = 0
		lbl.font = .fontRailwayBold(14)
		lbl.textColor = .white
		lbl.textAlignment = .center
		return lbl
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		layer.cornerRadius = 4
		layer.masksToBounds = true
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupConstraints() {
		contentView.addSubview(posterView)
		contentView.addSubview(titleLbl)

		posterView.pinToView(contentView)
		titleLbl.center(centerX: contentView.centerXAnchor, centerY: contentView.centerYAnchor)
		titleLbl.anchor(leading: contentView.leadingAnchor, paddingLeading: 12,
						trailing: contentView.trailingAnchor, paddingTrailing: -12)
	}
	
}
