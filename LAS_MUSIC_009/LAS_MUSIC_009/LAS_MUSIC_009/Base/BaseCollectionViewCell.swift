//
//  BaseCollectionViewCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 29/08/2023.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .clear
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
