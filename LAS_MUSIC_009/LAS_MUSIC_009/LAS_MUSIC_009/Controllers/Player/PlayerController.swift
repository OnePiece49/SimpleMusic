//
//  PlayerController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 15/08/2023.
//

import UIKit
import MediaPlayer
import SDWebImage
import WebKit
import AVFoundation

protocol PlayerControllerDelegate: AnyObject {
    func presentPlayerVCFullScreen()
}

class PlayerController: BaseController {
    
    //MARK: - Properties
    let loadingIndicator = UIActivityIndicatorView(style: .white)
    let thumbnailIV = UIImageView(frame: .zero)
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    var viewModel: PlayerViewModel = PlayerViewModel(playlist: PlaylistModel(), currentMusic: MusicModel())
    
    private var isSeeking: Bool = false
    private var playingInfo = [String: Any]()
    private var timeObserverToken: Any?
    private var isPlaying: Bool = true
	private var listMusicVC: ListMusicController?
	weak var delegate: PlayerControllerDelegate?
    
    // MARK: - Player
    var smallSize: Bool {
        return heightDevice <= 812
    }
    
    private lazy var playerLayer = AVPlayerLayer(player: player)
    let player: AVPlayer = AVPlayer()
    
    private var webView: WKWebView!
    
    // MARK: - Header: miniPLayerView + Poster + name + artist + progress + time
    lazy var miniPLayerView: MiniPlayerView = {
        let view = MiniPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentFullScreenPlayer))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        view.delegate = self
        return view
    }()
    
    private lazy var miniSizeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: AssetConstant.ic_make_mini)?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(miniSizeButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var convertButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Conver Audio", for: .normal)
        btn.setTitleColor(UIColor(rgb: 0xF4FE88), for: .normal)
        btn.titleLabel?.font = .fontRailwayBold(14)
        btn.setImage(UIImage(named: AssetConstant.ic_convert)?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.semanticContentAttribute = .forceLeftToRight
        btn.titleEdgeInsets.left = 13
        btn.imageEdgeInsets.left = 1
        btn.tintColor = UIColor(rgb: 0xFFFFFF)
        btn.addTarget(self, action: #selector(handleConvertButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var miniLayerPlayerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        loadingIndicator.setDimensions(width: 50, height: 50)
        loadingIndicator.layer.zPosition = 10
        return view
    }()
    
    private lazy var posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: AssetConstant.ic_thumbnail_default)
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var nameMusicLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .fontRailwayBold(28)
        label.textColor = UIColor(rgb: 0xEEEEEE)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .fontRailwayRegular(18)
        label.textColor = UIColor(rgb: 0xEEEEEE)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var progressSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.minimumTrackTintColor = UIColor(rgb: 0xF4FE88)
        slider.maximumTrackTintColor = UIColor(rgb: 0xBDB9B9).withAlphaComponent(0.13)
        slider.addTarget(self, action: #selector(handleSliderMoved), for: .allTouchEvents)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setThumbImage(UIImage(named: AssetConstant.ic_progress)?.withRenderingMode(.alwaysOriginal), for: .normal)
        return slider
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .fontRobotoRegular(14)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "0:00"
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .fontRobotoRegular(14)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "0:00"
        return label
    }()
    
    private lazy var nameAndArtistStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameMusicLabel, artistLabel])
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - activity stackView
    private lazy var dowloadButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: AssetConstant.ic_download_player)?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(didTapDownloadButton), for: .touchUpInside)
        return btn
    }()
    
    private lazy var listSongButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: AssetConstant.ic_current_playlist)?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(didTapListSongButton), for: .touchUpInside)
        return btn
    }()
    
    private lazy var shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: AssetConstant.ic_share)?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        return btn
    }()
    
    private lazy var addSongButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: AssetConstant.ic_add_song)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAddSongButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: AssetConstant.ic_heart)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleLikeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var activityStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dowloadButton,
                                                       listSongButton,
                                                       shareButton,
                                                       addSongButton,
                                                       likeButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    // MARK: - action stackView
    private lazy var randomButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: AssetConstant.ic_not_random)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleShuffleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: AssetConstant.ic_back_song)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.ic_is_playing)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleToFill
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(handlePlayButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: AssetConstant.ic_next)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleNextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var replayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: AssetConstant.ic_not_replay)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleReplayButtonTapped), for: .touchUpInside)
        return button
    }()
    

    private lazy var actionStackview: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [randomButton,
                                                       backButton,
                                                       playButton,
                                                       nextButton,
                                                       replayButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(miniSizeButton)
        view.addSubview(convertButton)
        view.addSubview(miniLayerPlayerView)
        view.addSubview(posterImageView)
        view.addSubview(nameAndArtistStackView)
        view.addSubview(activityStackView)
        view.addSubview(progressSlider)
        view.addSubview(currentTimeLabel)
        view.addSubview(totalTimeLabel)
        view.addSubview(actionStackview)
        
        NSLayoutConstraint.activate([
            miniSizeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            miniSizeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            
            convertButton.centerYAnchor.constraint(equalTo: miniSizeButton.centerYAnchor),
            convertButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            
            miniLayerPlayerView.topAnchor.constraint(equalTo: convertButton.bottomAnchor, constant: smallSize ? 22 : 63),
            miniLayerPlayerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            miniLayerPlayerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            miniLayerPlayerView.heightAnchor.constraint(equalTo: miniLayerPlayerView.widthAnchor, multiplier: 211 / 375),
            
            posterImageView.topAnchor.constraint(equalTo: convertButton.bottomAnchor, constant: 81),
            posterImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            posterImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            posterImageView.heightAnchor.constraint(equalTo: miniLayerPlayerView.widthAnchor, multiplier: 211 / 375),
            
            nameAndArtistStackView.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: smallSize ? 14 : 39),
            nameAndArtistStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14),
            nameAndArtistStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14),
            
            activityStackView.topAnchor.constraint(equalTo: nameAndArtistStackView.bottomAnchor, constant: smallSize ? 35 : 63),
            activityStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 55),
            activityStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            activityStackView.heightAnchor.constraint(equalToConstant: 35),
            
            progressSlider.topAnchor.constraint(equalTo: activityStackView.bottomAnchor, constant: 33),
            progressSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            progressSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            
            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 6),
            currentTimeLabel.leftAnchor.constraint(equalTo: progressSlider.leftAnchor),
            
            totalTimeLabel.topAnchor.constraint(equalTo: currentTimeLabel.topAnchor),
            totalTimeLabel.rightAnchor.constraint(equalTo: progressSlider.rightAnchor),
            
            actionStackview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 17),
            actionStackview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -17),
            actionStackview.centerYAnchor.constraint(equalTo: totalTimeLabel.bottomAnchor, constant: 32),
            actionStackview.heightAnchor.constraint(equalToConstant: 73),
        ])
        miniSizeButton.setDimensions(width: 35, height: 35)
        convertButton.setDimensions(width: 150, height: 35)
        shareButton.setDimensions(width: 35, height: 35)
        randomButton.setDimensions(width: 35, height: 35)
        addSongButton.setDimensions(width: 35, height: 35)
        likeButton.setDimensions(width: 35, height: 35)
       
        playButton.setDimensions(width: 73, height: 73)
        nextButton.setDimensions(width: 35, height: 35)
        backButton.setDimensions(width: 35, height: 35)
        replayButton.setDimensions(width: 35, height: 35)
        return view
    }()


    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.bindingNewPlaylist = { [weak self] in
            self?.updatePlayer()
            self?.randomButton.setImage(self?.viewModel.randomImage, for: .normal)
			self?.replayButton.setImage(self?.viewModel.replayImage, for: .normal)
            
            if self?.viewModel.isOffline == false {
                self?.convertButton.alpha = 0.5
                self?.convertButton.isUserInteractionEnabled = false
            } else {
                self?.convertButton.alpha = 1
                self?.convertButton.isUserInteractionEnabled = true
            }
        }
        
        configureWebView()
        configureUI()
        addObserve()
        setupRomoteCommander()
        setupRemoteComanderView()
    }

	deinit {
		NotificationCenter.default.removeObserver(self)
		removeTimeObserver()
	}

	private func configureUI() {
		view.addSubview(miniPLayerView)
		view.addSubview(containerView)

		NSLayoutConstraint.activate([
			miniPLayerView.topAnchor.constraint(equalTo: view.topAnchor),
			miniPLayerView.leftAnchor.constraint(equalTo: view.leftAnchor),
			miniPLayerView.rightAnchor.constraint(equalTo: view.rightAnchor),
			miniPLayerView.heightAnchor.constraint(equalToConstant: MiniPlayerView.heightView),

			containerView.topAnchor.constraint(equalTo: miniPLayerView.bottomAnchor),
			containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
			containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
			containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])

		view.layoutIfNeeded()
		playerLayer.frame = miniLayerPlayerView.bounds
		playerLayer.backgroundColor = UIColor.black.cgColor
		miniLayerPlayerView.layer.addSublayer(playerLayer)
	}
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            switch status {
            case .readyToPlay:
                player.play()
                progressSlider.isUserInteractionEnabled = true
            case .failed: return
            case .unknown: return
            @unknown default: return
            }
        }
        

    }
  
    //MARK: - Helpers
    private func configureWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "WebViewControllerMessageHandler")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsAirPlayForMediaPlayback = false //mute voice webview
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        webView.isHidden = true
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    
    private func updatePlayer() {
		self.posterImageView.sd_setImage(with: viewModel.thumbnailUrl, placeholderImage: UIImage(named: AssetConstant.ic_thumbnail_default), context: .none)
        self.nameMusicLabel.text = viewModel.nameMusic
        self.artistLabel.text = viewModel.nameArtist

        self.isPlaying = true
        self.playButton.setImage(UIImage(named: AssetConstant.ic_is_playing)?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.miniPLayerView.isPlaying = true
        self.miniPLayerView.music = viewModel.currentMusic
        self.posterImageView.isHidden = viewModel.isVideoType
        self.likeButton.setImage(viewModel.likeImage, for: .normal)

		if let listMusicVC = listMusicVC {
			listMusicVC.currentIndex = viewModel.currentIndex ?? 0
		}

        if viewModel.isOffline == false {
            self.loadYoutube()
            self.convertButton.alpha = 0.5
            self.convertButton.isUserInteractionEnabled = false
            self.dowloadButton.alpha = 1
            self.dowloadButton.isUserInteractionEnabled = true

        } else {
            guard let url = viewModel.currentVideoUrl else {return}
            let item = AVPlayerItem(url: url)
            item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
            player.replaceCurrentItem(with: item)
            progressSlider.isUserInteractionEnabled = false
            self.convertButton.alpha = 1
            self.convertButton.isUserInteractionEnabled = true
            self.dowloadButton.alpha = 0.5
            self.dowloadButton.isUserInteractionEnabled = false
            self.totalTimeLabel.text = viewModel.duration
			self.setupRemoteComanderView()
        }
    }
    
    private func loadYoutube() {
		guard let url = viewModel.currentVideoUrl else { return }
        let urlRequest = URLRequest(url: url)
        loadingIndicator.startAnimating()
        self.webView.load(urlRequest)
    } 
    
    private func addObserve() {
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(updateRemoteCommander),
//                                               name: .avplayerVCDeinit,
//                                               object: nil)
            
        addTimeObserver()
        addNotification()
    }
    
    private func setupRomoteCommander() {
        let commander = MPRemoteCommandCenter.shared()
        
        commander.playCommand.addTarget { event in
            self.playMedia()
            return .success
        }
        
        commander.pauseCommand.addTarget { event in
            self.pauseMedia()
            return .success
        }
        
        commander.nextTrackCommand.addTarget { event in
            self.nextMedia()
            return .success
        }
        
        commander.previousTrackCommand.addTarget { event in
            self.previousMedia()
            return .success
        }
    }
    
    private func setupRemoteComanderView(rate: Int = 1, duration: CMTime? = nil) {
        guard let music = viewModel.currentMusic else {return}
        playingInfo[MPMediaItemPropertyTitle] = music.name
        playingInfo[MPMediaItemPropertyArtist] = music.artist
        playingInfo[MPMediaItemPropertyPlaybackDuration] = (duration != nil) ? duration?.seconds : music.durationDouble
        playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
        playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate

		thumbnailIV.sd_setImage(with: viewModel.thumbnailUrl) { image, _, _, _ in
			let thumbnail = image ?? UIImage(named: AssetConstant.ic_thumbnail_default)!
			self.playingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 200, height: 200), requestHandler: { _ in
				return thumbnail
			})
		}

        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.playingInfo
    }

    private func playMedia() {
        self.handlePlayButtonTapped()
    }

    private func pauseMedia() {
        self.handlePlayButtonTapped()
    }
    
    private func nextMedia() {
        self.handleNextButtonTapped()

		thumbnailIV.sd_setImage(with: viewModel.thumbnailUrl) { image, _, _, _ in
			let thumbnail: UIImage = image ?? UIImage(named: AssetConstant.ic_thumbnail_default)!
			self.playingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 200, height: 200), requestHandler: { _ in
				return thumbnail
			})
		}
    }

    private func previousMedia() {
        self.handleBackButtonTapped()

		thumbnailIV.sd_setImage(with: viewModel.thumbnailUrl) { image, _, _, _ in
			let thumbnail: UIImage = image ?? UIImage(named: AssetConstant.ic_thumbnail_default)!
			self.playingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 200, height: 200), requestHandler: { _ in
				return thumbnail
			})
		}
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval,
														   queue: .main, using: { [weak self] currentTime in
            if self?.isSeeking == false {
                self?.updateVideoPlayerState(currentTime: currentTime)
            }
        })
    }

    private func updateVideoPlayerState(currentTime: CMTime) {
        guard let duration = player.currentItem?.duration else { return }
        let value = Float(currentTime.seconds / duration.seconds)
        progressSlider.value = value
        currentTimeLabel.text = currentTime.getTimeString()
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            self.timeObserverToken = nil
        }
    }
    
    private func updateNextButton() {
        if viewModel.replayMode == .ones || viewModel.replayMode == .all  {
            self.nextButton.alpha = 1
            self.nextButton.isUserInteractionEnabled = true
        } else if viewModel.replayMode == .none && viewModel.isLastSong {
            self.nextButton.alpha = 0.5
            self.nextButton.isUserInteractionEnabled = false
        } else if viewModel.replayMode == .none && !viewModel.isLastSong {
            self.nextButton.alpha = 1
            self.nextButton.isUserInteractionEnabled = true
        }
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleWhenLikeButtonTapped),
                                               name: .updateLikeButtonToPlayerController, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinishPlay),
                                               name: .AVPlayerItemDidPlayToEndTime, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleAppWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruptionPhoneCall),
											   name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    private func updateTimeLabel(progressTime: CMTime) {
        currentTimeLabel.text = progressTime.getTimeString()
    }
    
    //MARK: - Selectors
	@objc func handleInterruptionPhoneCall(notification: Notification) {
		guard let info = notification.userInfo,
			  let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
			  let type = AVAudioSession.InterruptionType(rawValue: typeValue)
		else { return }

		if type == .began {
			self.player.pause()

		} else if type == .ended {
			guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
			let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
			if options.contains(.shouldResume) {
				self.player.play()
			}
		}
	}
    
//    @objc func updateRemoteCommander() {
//        self.setupRomoteCommander()
//        self.setupRemoteComanderView(rate: Int(player.rate))
//    }
    
    @objc func handleConvertButtonTapped() {
        let convertVC = AudioConvertSheetController()
        convertVC.modalPresentationStyle = .overFullScreen
        convertVC.delegate = self
        self.present(convertVC, animated: false)
    }
    
    @objc func handleAppDidEnterBackground() {
        guard let tracks = player.currentItem?.tracks else { return }
        for track in tracks {
            if let assetTrack = track.assetTrack {
                if assetTrack.hasMediaCharacteristic(.visual) {
					print("DEBUG: ENABLE VIDEO TRACK FALSE")
                    track.isEnabled = false
                }
            }
        }
    }
    
    @objc func handleAppWillEnterForeground() {
        guard let tracks = player.currentItem?.tracks else { return }
        for track in tracks {
            if let assetTrack = track.assetTrack {
                if assetTrack.hasMediaCharacteristic(.visual) {
					print("DEBUG: ENABLE VIDEO TRACK TRUE")
                    track.isEnabled = true
                }
            }
        }
    }
    
    @objc func miniSizeButtonTapped() {
        guard let tabBarVC = self.parent as? TabBarController else {return}
        
        UIView.animate(withDuration: 0.2) {
            self.view.frame.origin.y = tabBarVC.heightDevice -  MiniPlayerView.heightView - tabBarVC.heightTabBar 
            tabBarVC.tabBar.frame.origin.y = tabBarVC.positionHiddentTabBar - tabBarVC.heightTabBar
        }

    }
    
    @objc func didTapListSongButton() {
		if listMusicVC == nil {
			listMusicVC = ListMusicController(playlist: viewModel.getCurrentPlaylist(),
											  currentIndex: viewModel.currentIndex ?? 0)
			listMusicVC?.modalPresentationStyle = .overFullScreen
			listMusicVC?.delegate = self
			listMusicVC?.willEndDissmiss = { [weak self] in
				self?.listMusicVC = nil
			}
			present(listMusicVC!, animated: false)
		}
    }
    
    @objc func didTapDownloadButton() {
        guard let asset = player.currentItem?.asset as? AVURLAsset  else {return}
        dowloadButton.alpha = 0.5
        dowloadButton.isUserInteractionEnabled = false
        
        viewModel.downloadMusic(url: asset.url) { [weak self] success in
            if success {
                self?.view.displayToast("Download music successfully")
            } else {
                self?.view.displayToast("Download music failed, file is existed")
            }
            
            if self?.viewModel.isOffline == false {
                self?.dowloadButton.alpha = 1
                self?.dowloadButton.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc func didTapShareButton() {
		let objectsToShare: [Any] = [viewModel.currentVideoUrl as Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @objc func handleWhenLikeButtonTapped(notification: Notification) {
        self.likeButton.setImage(viewModel.likeImage, for: .normal)
    }
    
    @objc func handleSliderMoved(_ sender: UISlider, forEvent event: UIEvent) {
        
        guard let duration = player.currentItem?.duration, duration.value != 0 else { return }
        let totalTime = CMTimeGetSeconds(duration)
        
        if totalTime == Float64.infinity || totalTime == Float64.nan {return}
        
        let value = Float64(sender.value) * totalTime
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)

        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
                case .began:
                    isSeeking = true
                case .ended:
					player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self]  _ in
						self?.isSeeking = false
						self?.setupRemoteComanderView(rate: 1, duration: duration)
					}
                default:
                    break
            }
        }
        updateTimeLabel(progressTime: seekTime)
    }
    
    @objc func playerItemDidFinishPlay() {
        let status = viewModel.itemDidFinishPlay()

        if viewModel.replayMode == .ones {
            player.seek(to: .zero)
            player.play()
            return
        }
        
        switch status {
        case .isLastSong:
            self.playButton.setImage(UIImage(named: AssetConstant.ic_is_pausing)?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.miniPLayerView.isPlaying = false
            self.nextButton.alpha = 0.4
            self.nextButton.isUserInteractionEnabled = false
            player.seek(to: CMTime(seconds: .zero, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { [weak self]  _ in
                self?.isPlaying = false
                self?.setupRemoteComanderView(rate: self!.isPlaying ? 1 : 0)
            }
        case .normal, .replayFromStart:
            self.updatePlayer()
            self.nextButton.alpha = 1
            self.nextButton.isUserInteractionEnabled = true
        }
    }
    
    @objc func presentFullScreenPlayer() {
        delegate?.presentPlayerVCFullScreen()
    }

    @objc func handlePlayButtonTapped() {
        if self.isPlaying {
            player.pause()
            self.playButton.setImage(UIImage(named: AssetConstant.ic_is_pausing)?.withRenderingMode(.alwaysOriginal), for: .normal)
			self.setupRemoteComanderView(rate: 0, duration: player.currentItem?.duration)
        } else {
            player.play()
            self.playButton.setImage(UIImage(named: AssetConstant.ic_is_playing)?.withRenderingMode(.alwaysOriginal), for: .normal)
			self.setupRemoteComanderView(rate: 1, duration: player.currentItem?.duration)
        }

        self.isPlaying = !isPlaying
        self.miniPLayerView.isPlaying = isPlaying
    }
    
    @objc func handleShuffleButtonTapped() {
        self.viewModel.shuffle(isPlaying: viewModel.currentMusic)
        self.randomButton.setImage(viewModel.randomImage, for: .normal)
        self.updateNextButton()
    }
    
    @objc func handleReplayButtonTapped() {
        self.viewModel.updateReplayMode()
        self.replayButton.setImage(viewModel.replayImage, for: .normal)
        updateNextButton()
    }

    @objc func handleBackButtonTapped() {
        self.webView.stopLoading()
        let success = viewModel.backSong()
        if success == true {
            updatePlayer()
            updateNextButton()
        }
    }
   
    @objc func handleNextButtonTapped() {
        self.webView.stopLoading()
        let status = viewModel.nextSong()
        
        switch status {
        case .isLastSong:
            self.playButton.setImage(UIImage(named: AssetConstant.ic_is_pausing)?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.miniPLayerView.isPlaying = false
            self.nextButton.alpha = 0.7
            self.nextButton.isUserInteractionEnabled = false
            player.seek(to: CMTime(seconds: .zero, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { [weak self]  _ in
                self?.isPlaying = false
                self?.setupRemoteComanderView(rate: self!.isPlaying ? 1 : 0)
            }
        case .normal, .replayFromStart:
            self.updatePlayer()
        }
        updateNextButton()
    }
    
    @objc func handleLikeButtonTapped() {
        let _ = viewModel.toogleLikeMusic()
        self.likeButton.setImage(viewModel.likeImage, for: .normal)

		if let music = viewModel.currentMusic {
			NotificationCenter.default.post(name: .updateLikeButtonToOtherControllers,
											object: nil, userInfo: ["music": music])
		}
    }
    
    @objc func handleAddSongButtonTapped() {
        guard let music = viewModel.currentMusic else {return}
		let addToVC = AddToPlaylistController(music: music)
        self.present(addToVC, animated: true)
    }
    
}

//MARK: - delegate MiniPlayerViewDelegate
extension PlayerController: MiniPlayerViewDelegate {
    func didTapPlayPause(_ miniPlayer: MiniPlayerView) {
        handlePlayButtonTapped()
    }
    
    func didTapNextMedia(_ miniPlayer: MiniPlayerView) {
        handleNextButtonTapped()
    }
}

//MARK: - delegate AudioConvertSheetDelegate
extension PlayerController: AudioConvertSheetDelegate {
    func didSelectMediaCell(type: ConvertAudioType) {
        guard let outputString = viewModel.currentVideoUrl?.deletingPathExtension().lastPathComponent else {return}
        guard let output = URL.audioFolder()?.appendingPathComponent(outputString).appendingPathExtension(type.pathExtension) else {
            return
        }
        
        if FileManager.default.fileExists(atPath: output.path) {
            self.view.displayToast("Convert failed, file is existed")
            return
        }
        
        self.convertButton.setTitle("Converting", for: .normal)
        self.convertButton.alpha = 0.5
        self.convertButton.isUserInteractionEnabled = false
        
        viewModel.convertVideo(type: type) { [weak self] success in
            self?.convertButton.setTitle("Convert Audio", for: .normal)
            self?.convertButton.alpha = 1
            self?.convertButton.isUserInteractionEnabled = true
            
            let message = success ? "Convert Audio Successfully" : "Convert Audio Failed"
            self?.view.displayToast(message)
        }
    }
}

//MARK: - delegate ListMusicControllerDelegate
extension PlayerController: ListMusicControllerDelegate {
    func didSelectMediaCell(music: MusicModel) {
        let success = viewModel.playMusic(music: music)
        if success == true {
            self.updatePlayer()
            self.updateNextButton()
        }
    }
    
}

//MARK: - delegate WKNavigationDelegate, WKScriptMessageHandler
extension PlayerController: WKNavigationDelegate, WKScriptMessageHandler {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        let js = """
        let length = document.getElementsByTagName('video').length
         if (length == 0) {
            window.webkit.messageHandlers.WebViewControllerMessageHandler.postMessage({ "src": [0] });
         }
        for(let i = 0; i < length; i++) {
            let video = document.getElementsByTagName('video')[i];
            let src = video.src;
            window.webkit.messageHandlers.WebViewControllerMessageHandler.postMessage({ "src": src });
        }
        """
        
        self.webView.evaluateJavaScript(js)
        self.webView.stopLoading()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        loadingIndicator.stopAnimating()
        guard let body = message.body as? [String: Any] else {
            print("DEBUG: 0.0.0.0.0.0 could not convert message body to dictionary: \(message.body)")
            return
        }
        
        guard let urlString = body["src"] as? String else {
            return
        }

        guard let url = URL(string: urlString) else {return}
        let item = AVPlayerItem(url: url)
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
        player.replaceCurrentItem(with: item)
        progressSlider.isUserInteractionEnabled = false
        
        DispatchQueue.global().async {
            let timeDuration = AVAsset(url: url).duration
            let duration = timeDuration.getTimeString()
            
            DispatchQueue.main.async {
                self.totalTimeLabel.text = duration
                try? RealmService.shared.realmObj()?.write({
                    self.viewModel.currentMusic?.durationDouble = timeDuration.seconds
                })
                
                try? RealmService.shared.realmObj()?.write({
                    self.viewModel.currentMusic?.durationString = duration
                    self.setupRemoteComanderView(rate: 1, duration: timeDuration)
                })
                
            }
        }
    }
}
