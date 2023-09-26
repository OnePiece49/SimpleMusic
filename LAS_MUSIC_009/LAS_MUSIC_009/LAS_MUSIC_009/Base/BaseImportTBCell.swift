//
//  BaseImportTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 14/08/2023.
//

import UIKit

class BaseImportTBCell: BaseTableViewCell {
    
    //MARK: - Properties
    static let heightCell: CGFloat = 90
    
    lazy var nameLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = .white
        label.font = .fontRailwayRegular(15)
        return label
    }()
    
    lazy var fileSizeLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(rgb: 0x979797)
        label.font = .fontRailwayRegular(13)
        return label
    }()
    
    lazy var downloadBtn: UIButton = {
        let button = UIButton(type: .system)
		button.isUserInteractionEnabled = false
        button.setImage(UIImage(named: AssetConstant.ic_download)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - View Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Helpers
    func configureUI() {
        contentView.addSubview(nameLbl)
        contentView.addSubview(fileSizeLbl)
        contentView.addSubview(downloadBtn)
        
        NSLayoutConstraint.activate([
            nameLbl.leftAnchor.constraint(equalTo: leftAnchor, constant: 26),
            nameLbl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 19),
            nameLbl.rightAnchor.constraint(equalTo: downloadBtn.leftAnchor, constant: -13),
            
            
            downloadBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -26),
            downloadBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            fileSizeLbl.leftAnchor.constraint(equalTo: leftAnchor, constant: 26),
            fileSizeLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 6),
            fileSizeLbl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -19),
            fileSizeLbl.heightAnchor.constraint(equalToConstant: 20)
            
        ])
        downloadBtn.setDimensions(width: 35, height: 35)
    }

	func getFileSize(byte: Int64) -> String {
		return ByteCountFormatter.string(fromByteCount: byte, countStyle: .file)
	}

}
