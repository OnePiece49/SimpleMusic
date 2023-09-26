//
//  FilterCLCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 22/08/2023.
//

import UIKit

class FilterCLCell: UICollectionViewCell {
    //MARK: - Properties
    
    private lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xEEEEEE)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    var celltype: SearchFilter? {
        didSet {
            updateUI()
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .fontRailwayBold(16)
        label.textColor = UIColor(rgb: 0x71737B)
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
    func configureUI() {
        addSubview(titleLabel)
        addSubview(progressView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.widthAnchor.constraint(equalTo: widthAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4),
        ])
        
    }
    
    func updateUI() {
        self.titleLabel.text = self.celltype?.title
    }
    
    func updateSelected(isSelect: Bool) {
        if isSelect {
            progressView.isHidden = false
            titleLabel.textColor =  UIColor(rgb: 0xEEEEEE)
            titleLabel.font = .fontRailwayBold(24)
        } else {
            progressView.isHidden = true
            titleLabel.textColor = UIColor(rgb: 0x71737B)
            titleLabel.font = .fontRailwayBold(16)
        }
    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate


