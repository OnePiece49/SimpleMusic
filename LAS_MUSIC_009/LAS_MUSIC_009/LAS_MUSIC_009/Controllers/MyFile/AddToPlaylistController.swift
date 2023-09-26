//
//  AddToPlaylistController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 16/08/2023.
//


import UIKit

class AddToPlaylistController: MyFileBaseController {

	private let viewModel: AddToPlaylistViewModel

    // MARK: - UI components
	private let createPlaylistView: CreatePlaylistView = {
		let view = CreatePlaylistView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.option = .create
		return view
	}()
    
    private lazy var createPlaylistBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Add New Playlist", for: .normal)
        btn.setTitleColor(UIColor(rgb: 0x20242F), for: .normal)
        btn.backgroundColor = .secondaryYellow
        btn.titleLabel?.font = .fontRailwayBold(16)
        btn.layer.cornerRadius = isIphone ? 4 : 8
        btn.addTarget(self, action: #selector(createNewPlaylist), for: .touchUpInside)
        return btn
    }()

    // MARK: - Life cycle
	init(music: MusicModel) {
		self.viewModel = AddToPlaylistViewModel(music: music)
		super.init(type: .playlist)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        view.addSubview(createPlaylistBtn)
        setupTBView()
        bindViewModel()
		createPlaylistView.delegate = self
		super.viewDidLoad()
    }

    private func setupTBView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddToPlaylistTBCell.self, forCellReuseIdentifier: AddToPlaylistTBCell.cellId)
    }

    override func setupConstraints() {
        navBar.anchor(leading: view.leadingAnchor,
                      top: view.safeAreaLayoutGuide.topAnchor,
                      trailing: view.trailingAnchor, height: 44)

        createPlaylistBtn.anchor(leading: view.leadingAnchor, paddingLeading: isIphone ? 20 : 40,
                                 top: navBar.bottomAnchor, paddingTop: 12,
                                 trailing: view.trailingAnchor, paddingTrailing: isIphone ? -20 : -40,
                                 height: isIphone ? 40 : 60)

        tableView.anchor(leading: view.leadingAnchor,
                         top: createPlaylistBtn.bottomAnchor, paddingTop: 12,
                         trailing: view.trailingAnchor,
                         bottom: view.bottomAnchor)
        
        view.addSubview(createPlaylistView)

        createPlaylistView.anchor(leading: view.leadingAnchor,
                                 top: view.topAnchor, paddingTop: 0,
                                 trailing: view.trailingAnchor,
                                 bottom: view.bottomAnchor)
        navBar.leftButtons.first?.isHidden = true

    }
}

// MARK: - Method
extension AddToPlaylistController {
    @objc private func createNewPlaylist() {
        createPlaylistView.show()
    }

    private func bindViewModel() {
        viewModel.onCreatePlaylist = { [weak self] indexPath in
			self?.tableView.insertRows(at: [indexPath], with: .automatic)
        }

		viewModel.onAddMusicToPlaylist = { [weak self] message, indexPath in
			self?.tableView.isUserInteractionEnabled = true
			self?.tableView.reloadRows(at: [indexPath], with: .automatic)
			self?.view.displayToast(message)
		}

        viewModel.loadAllPlaylists()
    }
}

// MARK: - CreatePlaylistViewDelegate
extension AddToPlaylistController: CreatePlaylistViewDelegate {
	func didTapOkButton(with name: String, option: CreatePlaylistView.Option) {
		if option == .create {
			if name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
				self.view.displayToast("Name playlist is invalid")
				return
			}

			let success = viewModel.createNewPlaylist(name: name)
			if success {
				self.view.displayToast("Create playlist \(name) successfully")
			} else {
				self.view.displayToast("Create playlist \(name) failed")
			}
		}
	}
}

// MARK: - UITalbeViewDelegate
extension AddToPlaylistController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddToPlaylistTBCell.cellId,
                                                 for: indexPath) as! AddToPlaylistTBCell
        cell.playlist = viewModel.getPlaylist(at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.isUserInteractionEnabled = false
		viewModel.addMusicToPlaylist(at: indexPath)
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return AddToPlaylistTBCell.cellHeight
	}
}
