//
//  ListMusicTBCell.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 23/08/2023.
//

import UIKit


import UIKit
import MediaPlayer

class ListMusicTBCell: BaseTableViewCell {
    
    // MARK: - UI components
    let posterImageView: UIImageView = {
        let imv = UIImageView()
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.contentMode = .scaleAspectFill
        imv.layer.cornerRadius = 10
        imv.clipsToBounds = true
        return imv
    }()

    let musicTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .fontRailwaySemiBold(16)
        label.textColor = UIColor(rgb: 0xEEEEEE)
        label.textAlignment = .left
        return label
    }()

    let artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .fontRailwayRegular(12)
        label.textColor = UIColor(rgb: 0x71737B)
        label.textAlignment = .left
        return label
    }()
    
    lazy var playImageView: UIImageView = {
        let iv = UIImageView()
		iv.translatesAutoresizingMaskIntoConstraints = false
		iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: AssetConstant.ic_choose_image)
        iv.isHidden = true
        return iv
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func setupConstraints() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(musicTitleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(playImageView)

        NSLayoutConstraint.activate([
            posterImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            posterImageView.widthAnchor.constraint(equalToConstant: 93),
            posterImageView.heightAnchor.constraint(equalToConstant: 59),
            posterImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            musicTitleLabel.leftAnchor.constraint(equalTo: posterImageView.rightAnchor, constant: 8),
            musicTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -72),
            musicTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -12),

            artistLabel.leftAnchor.constraint(equalTo: musicTitleLabel.leftAnchor),
            artistLabel.rightAnchor.constraint(equalTo: musicTitleLabel.rightAnchor),
            artistLabel.topAnchor.constraint(equalTo: musicTitleLabel.bottomAnchor, constant: 11),
            
            playImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            playImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
        ])
        playImageView.setDimensions(width: 22, height: 22)
    }
    
    // MARK: - Implement
    static let heightCell: CGFloat = 80
    var cellIdentifier = UUID().uuidString
    
    func shouldHiddenPlayButton(isHidden: Bool) {
        self.playImageView.isHidden = isHidden
    }
    
    var music: MusicModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let music = music else {return}
        
        self.musicTitleLabel.text = music.name
        self.artistLabel.text = music.artist
        self.posterImageView.sd_setImage(with: URL(string: music.thumbnailURL ?? ""), placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default))
    }
    
}
    
