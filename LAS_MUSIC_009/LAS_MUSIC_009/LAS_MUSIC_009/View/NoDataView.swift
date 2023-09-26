//
//  NoDataView.swift
//  LAS_MUSIC_009
//
//  Created by Đức Anh Trần on 17/08/2023.
//

import UIKit

class NoDataView: UIView {

	let noDataLbl: UILabel = {
		let lbl = UILabel()
		lbl.numberOfLines = 0
		lbl.font = .fontRailwaySemiBold(20)
		lbl.textColor = .white
		lbl.textAlignment = .center
		lbl.text = "No Data"
		return lbl
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupConstraints()
	}

	private func setupConstraints() {
		addSubview(noDataLbl)
		noDataLbl.centerX(centerX: centerXAnchor)
		noDataLbl.centerY(centerY: centerYAnchor, paddingY: -80)
	}
}
