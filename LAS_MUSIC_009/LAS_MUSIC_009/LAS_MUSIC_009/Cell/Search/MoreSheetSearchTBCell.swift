//
//  MoreSearchTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 22/08/2023.
//


import UIKit

enum MoreSheetSearchOption: Int, CaseIterable {
    case addToPlaylist
    case addToFav
    
    var description: String {
        switch self {
        case .addToPlaylist:
            return "Add To Playlist"
        case .addToFav:
            return "Add To Favourite"
        }
    }
}

class MoreSheetSearchTBCell: UITableViewCell {

    static let cellHeight: CGFloat = 50

    var cellType: MoreSheetSearchOption? {
        didSet {
            updateUI()
        }
    }
    
    private let titleLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .fontRailwayRegular(16)
        label.textColor = UIColor(rgb: 0xEEEEEE)
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConstraints()
    }

    private func setupConstraints() {
        contentView.addSubview(titleLbl)
        titleLbl.pinToView(contentView)
    }

    private func updateUI() {
        self.titleLbl.text = cellType?.description
    }
}

