//
//  FSPagerViewCell.swift
//  FSPagerView
//
//  Created by Wenchao Ding on 17/12/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage

open class FSPagerViewCell: UICollectionViewCell {

    
    // MARK: - Properties
    private let spacing: CGFloat = 12
    var album: YTAblumModel? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - UI components
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.alpha = 0.7
        blurEffectView.layer.cornerRadius = 10
        blurEffectView.clipsToBounds = true
        return blurEffectView
    }()
    
    private lazy var dimmingImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: AssetConstant.ic_thumbnail_default)
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
//        iv.alpha = 0.5
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    private lazy var posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: AssetConstant.ic_thumbnail_default)
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    private lazy var nameMusicLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .fontRailwayBold(16)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "Pink Venom"
        return label
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "Black Pink"
        return label
    }()
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    // MARK: - Setup
    
    private func updateUI() {
        self.posterImageView.sd_setImage(with: URL(string: album?.thumbnail ?? ""), placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default), context: .none)
        self.dimmingImageView.sd_setImage(with: URL(string: album?.thumbnail ?? ""), placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default), context: .none)
        self.artistLabel.text = album?.artist
        self.nameMusicLabel.text = album?.title
    }

    private func setupConstraints() {
    
        addSubview(dimmingImageView)
        addSubview(blurEffectView)
        addSubview(posterImageView)
        addSubview(nameMusicLabel)
        addSubview(artistLabel)

        NSLayoutConstraint.activate([
            
            dimmingImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: spacing),
            dimmingImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            dimmingImageView.topAnchor.constraint(equalTo: topAnchor, constant: spacing),
            dimmingImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor, constant: spacing),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            blurEffectView.topAnchor.constraint(equalTo: topAnchor, constant: spacing),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

            posterImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            posterImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -spacing),
            posterImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            posterImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -spacing),

            nameMusicLabel.leftAnchor.constraint(equalTo: posterImageView.leftAnchor, constant: 16),
            nameMusicLabel.rightAnchor.constraint(equalTo: posterImageView.rightAnchor, constant: -16),
            nameMusicLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            
            artistLabel.leftAnchor.constraint(equalTo: nameMusicLabel.leftAnchor, constant: 0),
            artistLabel.rightAnchor.constraint(equalTo: nameMusicLabel.rightAnchor, constant: -0),
            artistLabel.topAnchor.constraint(equalTo: nameMusicLabel.bottomAnchor, constant: 2),
            
        ])
    }

}
