//
//  BaseTableViewCell.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 29/08/2023.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .clear
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
