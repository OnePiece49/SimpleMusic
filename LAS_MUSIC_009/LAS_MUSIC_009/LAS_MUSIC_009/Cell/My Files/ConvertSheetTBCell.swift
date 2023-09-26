//
//  ConvertSheetTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 16/08/2023.
//

import UIKit

enum ConvertAudioType: Int, CaseIterable {
    case mp3
    case m4a
    case aac
    
    var title: String {
        switch self {
        case .mp3:
            return ".mp3"
        case .m4a:
            return ".m4a"
        case .aac:
            return ".aac"
        }
    }
    
    var pathExtension: String {
        switch self {
        case .mp3:
            return "mp3"
        case .m4a:
            return "m4a"
        case .aac:
            return "aac"
        }
    }
}

class ConvertSheetTBCell: UITableViewCell {

    // MARK: - Properties
    static let heightCell: CGFloat = 50

    var cellType: ConvertAudioType? {
        didSet {
            updateUI()
        }
    }
    
    private let titleLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .fontRailwayRegular(17)
        label.textColor = UIColor(rgb: 0xEEEEEE)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConstraints()
    }

    
    // MARK: - helpers
    private func setupConstraints() {
        contentView.addSubview(titleLbl)
        titleLbl.pinToView(contentView)
    }
    
    private func updateUI() {
        self.titleLbl.text = cellType?.title
    }


}
