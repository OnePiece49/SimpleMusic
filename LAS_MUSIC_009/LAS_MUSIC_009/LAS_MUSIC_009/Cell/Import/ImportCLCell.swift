//
//  ImportCLCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 14/08/2023.
//

import UIKit

class ImportCLCell: UICollectionViewCell {
    
    //MARK: - Properties
    var cellType: ImportType? {
        didSet {updateUI()}
    }
    
    private lazy var miniView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(rgb: 0xF4FE88).cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var importImv: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    
    private lazy var importLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .fontRailwayMedium(16)
        label.textColor = UIColor(rgb: 0xEEEEEE)
        return label
    }()
    

    
    //MARK: - View Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    private func configureUI() {
        addSubview(miniView)
        addSubview(importImv)
        addSubview(importLbl)
        
        NSLayoutConstraint.activate([
            miniView.centerXAnchor.constraint(equalTo: centerXAnchor),
            miniView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            miniView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.63),
            miniView.heightAnchor.constraint(equalTo: miniView.widthAnchor, multiplier: 1),
            
            importImv.centerXAnchor.constraint(equalTo: miniView.centerXAnchor),
            importImv.centerYAnchor.constraint(equalTo: miniView.centerYAnchor),
            importImv.widthAnchor.constraint(equalTo: miniView.widthAnchor, multiplier: 3 / 7),
            importImv.heightAnchor.constraint(equalTo: importImv.widthAnchor, multiplier: 1),
            
            importLbl.bottomAnchor.constraint(equalTo: miniView.bottomAnchor, constant: 30),
            importLbl.centerXAnchor.constraint(equalTo: miniView.centerXAnchor),
        ])

    }

    private func updateUI() {
        importLbl.text = cellType?.title
        importImv.image = cellType?.image?.withRenderingMode(.alwaysOriginal)
    }
    
    //MARK: - Selectors
    @objc func handleImportButtonTapped() {
        
    }
    
}
//MARK: - delegate
