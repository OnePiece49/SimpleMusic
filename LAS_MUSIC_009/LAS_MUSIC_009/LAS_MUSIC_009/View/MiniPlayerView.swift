//
//  MiniPlayerController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 15/08/2023.
//

import Foundation


import Foundation


import UIKit
import AVFoundation

protocol MiniPlayerViewDelegate: AnyObject {
    func didTapPlayPause(_ miniPlayer: MiniPlayerView)
    func didTapNextMedia(_ miniPlayer: MiniPlayerView)
}

class MiniPlayerView: UIView {

    // MARK: - UI components
    static let heightView: CGFloat = 73
    
    private let posterImageView: UIImageView = {
        let imv = UIImageView()
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        imv.layer.cornerRadius = 48/2
        imv.image = UIImage(named: AssetConstant.ic_thumbnail_default)
        return imv
    }()

    private let musicTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .fontRailwaySemiBold(16)
        label.textColor = UIColor(rgb: 0x20242F)
        label.textAlignment = .left
        label.text = "[Playlist] time for self..."
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: AssetConstant.ic_mini_back), for: .normal)
        btn.tintColor = UIColor(rgb: 0x000000)
        btn.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        btn.addTarget(self, action: #selector(didTapNextMediaButton), for: .touchUpInside)
        return btn
    }()

    private lazy var playMediaButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: AssetConstant.ic_mini_play), for: .normal)
        btn.layer.borderColor = UIColor(rgb: 0x000000).cgColor
        btn.layer.cornerRadius = 32/2
        btn.layer.masksToBounds = true
        btn.tintColor = UIColor(rgb: 0x000000)
        btn.addTarget(self, action: #selector(didTapPlayMediaButton), for: .touchUpInside)
        return btn
    }()

    private lazy var nextMediaButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: AssetConstant.ic_mini_next), for: .normal)
        btn.tintColor = UIColor(rgb: 0x000000)
        btn.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        btn.addTarget(self, action: #selector(didTapNextMediaButton), for: .touchUpInside)
        return btn
    }()

    // MARK: - Properties

    weak var delegate: MiniPlayerViewDelegate?

    var isPlaying: Bool = false {
        didSet {
            updatePlayPauseButton()
        }
    }
    
    var music: MusicModel? {
        didSet {
            configure()
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMusicReadyToPlay(_:)),
                                               name: .musicReadyToPlay, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = UIColor(rgb: 0xF4FE88)
        setupConstraints()
    }

    private func setupConstraints() {
        addSubview(posterImageView)
        addSubview(musicTitleLabel)
        addSubview(backButton)
        addSubview(playMediaButton)
        addSubview(nextMediaButton)

        NSLayoutConstraint.activate([
            posterImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            posterImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 48),
            posterImageView.heightAnchor.constraint(equalToConstant: 48),

            musicTitleLabel.leftAnchor.constraint(equalTo: posterImageView.rightAnchor, constant: 10),
            musicTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            musicTitleLabel.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, constant: -12),
            
            backButton.leftAnchor.constraint(equalTo: musicTitleLabel.rightAnchor, constant: 12),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            playMediaButton.leftAnchor.constraint(equalTo: backButton.rightAnchor, constant: 16),
            playMediaButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playMediaButton.widthAnchor.constraint(equalToConstant: 32),
            playMediaButton.heightAnchor.constraint(equalToConstant: 32),

            nextMediaButton.leftAnchor.constraint(equalTo: playMediaButton.rightAnchor, constant: 20),
            nextMediaButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            nextMediaButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            nextMediaButton.widthAnchor.constraint(equalToConstant: 24),
            nextMediaButton.heightAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    private func configure() {
        guard let music = music else { return }
        musicTitleLabel.text = music.name
        self.posterImageView.sd_setImage(with: URL(string: music.thumbnailURL ?? ""), placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default), context: .none)
    }

    // MARK: - Selectors

    @objc private func didTapPlayMediaButton() {
        delegate?.didTapPlayPause(self)
    }

    @objc private func didTapNextMediaButton() {
        delegate?.didTapNextMedia(self)
    }

    @objc private func handleMusicReadyToPlay(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isPlaying = userInfo["isPlaying"] as? Bool else { return }
        self.isPlaying = isPlaying
        updatePlayPauseButton()
    }

    // MARK: - Private methods

    private func updatePlayPauseButton() {
        let imgName = isPlaying ? AssetConstant.ic_mini_playing : AssetConstant.ic_mini_play
        playMediaButton.setImage(UIImage(named: imgName), for: .normal)
    }


}
