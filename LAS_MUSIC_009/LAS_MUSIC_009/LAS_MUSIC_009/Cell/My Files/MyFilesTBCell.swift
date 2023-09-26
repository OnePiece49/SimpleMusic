//
//  MyFilesTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 14/08/2023.
//

import UIKit

class MyFilesTBCell: UITableViewCell {
    
    //MARK: - Properties
    static let heightCell: CGFloat = 80
    
    private lazy var filesImv: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var filesLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = UIColor(rgb: 0xEEEEEE)
        label.textColor = .black
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filesImv)
        view.addSubview(filesLbl)
        
        NSLayoutConstraint.activate([
            filesImv.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            filesImv.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            
            filesLbl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 21),
            filesLbl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
        ])
        return view
    }()
    
    var celltype: MyFilesType? {
        didSet {
            updateUI()
        }
    }
    
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
        addSubview(containerView)
        backgroundColor = .black
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7),
        ])
    }
    
    func updateUI() {
        containerView.backgroundColor = celltype?.backgroundColor
        filesImv.image = celltype?.image?.withRenderingMode(.alwaysOriginal)
        filesLbl.text = celltype?.title
    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate

