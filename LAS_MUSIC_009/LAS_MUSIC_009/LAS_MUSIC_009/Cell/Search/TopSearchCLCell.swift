//
//  SearchCLCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 21/08/2023.
//

import UIKit

class TopSearchCLCell: UICollectionViewCell {
    //MARK: - Properties
    static let aligmentSearchLabel: CGFloat = 9.5
    static let alightmentSearchCell: CGFloat = 6
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(rgb: 0xF4FE88).cgColor
        view.isUserInteractionEnabled = false
        
        view.addSubview(searchButton)
        NSLayoutConstraint.activate([
            searchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchButton.heightAnchor.constraint(equalToConstant: 35),
            searchButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: TopSearchCLCell.aligmentSearchLabel),
            searchButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -TopSearchCLCell.aligmentSearchLabel)
        ])
        return view
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .fontRailwayRegular(14)
        button.setTitleColor(UIColor(rgb: 0xF4FE88), for: .normal)
        return button
    }()
    
    static let identifier = "ProfileCollectionViewCell"
    
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
        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: TopSearchCLCell.alightmentSearchCell),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -TopSearchCLCell.alightmentSearchCell),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func updateUI(text: String?) {
        searchButton.setTitle(text, for: .normal)
    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate
