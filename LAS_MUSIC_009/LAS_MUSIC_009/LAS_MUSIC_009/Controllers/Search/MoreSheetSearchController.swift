//
//  MoreSheetSearchVC.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 22/08/2023.
//

import UIKit


import UIKit
import MediaPlayer

protocol MoreSheetSearchVDelegate: AnyObject {
    func didSelectOption(option: MoreSheetSearchOption?, music: MusicModel)
}

enum SourceType {
    case online
    case offline
}

class MoreSheetSearchController: TransparentBottomSheetController {

    private enum Option: Int, CaseIterable {
        case addToPlaylist, share, delete

        var title: String {
            switch self {
                case .addToPlaylist: return "Add To Playlist"
                case .share: return "Share"
                case .delete: return "Delete"
            }
        }
    }
    
    private let musicOffline: MusicModel
    weak var delegate: MoreSheetSearchVDelegate?
    private let sourceType: SourceType
    
    // MARK: - UI components
    override var rootView: UIView {
        return containerView
    }

    override var sheetHeight: BottomSheetHeight {
        return .aspect(215/813)
    }

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let titleLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .fontRailwayBold(18)
        label.textColor = UIColor(rgb: 0xEEEEEE)
        label.textAlignment = .center
        return label
    }()

    private let tableView: UITableView = {
        let tbv = UITableView(frame: .zero, style: .plain)
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.backgroundColor = .clear
        tbv.isScrollEnabled = false
        return tbv
    }()

    // MARK: - Life cycle
    init(music: MusicModel, sourceType: SourceType) {
        self.musicOffline = music
        self.sourceType = sourceType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTBView()
        titleLbl.text = musicOffline.name
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.applyGradient(colours: [UIColor(rgb: 0x717171).withAlphaComponent(0.6),
                                                   UIColor(rgb: 0x545454).withAlphaComponent(0.6)])
    }

    private func setupTBView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MoreSheetSearchTBCell.self, forCellReuseIdentifier: MoreSheetSearchTBCell.cellId)
    }

    override func setupConstraints() {
        super.setupConstraints()
        containerView.addSubview(titleLbl)
        containerView.addSubview(tableView)

        titleLbl.anchor(leading: containerView.leadingAnchor, paddingLeading: 20,
                        top: containerView.topAnchor, paddingTop: 20,
                        trailing: containerView.trailingAnchor, paddingTrailing: -20)

        tableView.anchor(leading: titleLbl.leadingAnchor,
                         top: titleLbl.bottomAnchor, paddingTop: 12,
                         trailing: titleLbl.trailingAnchor,
                         bottom: containerView.bottomAnchor)
    }
}

// MARK: - UITableViewDelegate
extension MoreSheetSearchController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MoreSheetSearchOption.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreSheetSearchTBCell.cellId,
                                                 for: indexPath) as! MoreSheetSearchTBCell
        let option = MoreSheetSearchOption(rawValue: indexPath.row)
        cell.cellType = option
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.removeSheet {
            let option = MoreSheetSearchOption(rawValue: indexPath.row)
            self.delegate?.didSelectOption(option: option, music: self.musicOffline)
        }
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return MoreSheetSearchTBCell.cellHeight
	}
}
