//
//  AudioConvertSheetController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 16/08/2023.
//

import UIKit
import MediaPlayer

protocol AudioConvertSheetDelegate: AnyObject {
    func didSelectMediaCell(type: ConvertAudioType)
}

class AudioConvertSheetController: BottomSheetViewCustomController {
    
    //MARK: - Properties
    weak var delegate: AudioConvertSheetDelegate?

    override var durationAnimation: CGFloat {
        return 0.3
    }
    
    override var bottomSheetView: UIView {
        return containerView
    }
    
    override var heightBottomSheetView: CGFloat {
        return 300
    }
    
    override var maxHeightScrollTop: CGFloat {
        return 40
    }
    
    override var minHeightScrollBottom: CGFloat {
        return 300
    }
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 32
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
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
        tbv.separatorColor = .clear
        return tbv
    }()
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureProperties()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.applyGradient(colours: [UIColor(rgb: 0x717171).withAlphaComponent(0.6),
                                                   UIColor(rgb: 0x545454).withAlphaComponent(0.6)])
    }
    
    deinit {
        print("DEBUG: AudioConvertSheetController deinit")
    }
    
    //MARK: - Helpers
    func configTitle(with title: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributedTitle = NSMutableAttributedString(string: "Convert Video to Audio\n",
                                                        attributes: [.font: UIFont.fontRailwayBold(16),
                                                                     .foregroundColor: UIColor(rgb: 0xEEEEEE)])
        attributedTitle.append(NSAttributedString(string: title,
                                                  attributes: [.font: UIFont.fontRailwayBold(14),
                                                               .foregroundColor: UIColor(rgb: 0xF4FE88)]))
        attributedTitle.addAttribute(NSAttributedString.Key.paragraphStyle,
                                     value:paragraphStyle,
                                     range:NSMakeRange(0, attributedTitle.length))
        paragraphStyle.lineSpacing = 12
        
        self.titleLbl.attributedText = attributedTitle
    }
    
    func configureUI() {
        containerView.addSubview(titleLbl)
        containerView.addSubview(tableView)
        configTitle(with: "Choose File")
        
        titleLbl.anchor(leading: containerView.leadingAnchor, paddingLeading: 20,
                        top: containerView.topAnchor, paddingTop: 20,
                        trailing: containerView.trailingAnchor, paddingTrailing: -20)

        tableView.anchor(leading: titleLbl.leadingAnchor,
                         top: titleLbl.bottomAnchor, paddingTop: 12,
                         trailing: titleLbl.trailingAnchor,
                         bottom: containerView.bottomAnchor)
    }
    
    func configureProperties() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConvertSheetTBCell.self,
                           forCellReuseIdentifier: ConvertSheetTBCell.cellId)
    }
    
    //MARK: - Selectors
    
}
//MARK: - delegate
extension AudioConvertSheetController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConvertAudioType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConvertSheetTBCell.cellId,
                                                 for: indexPath) as! ConvertSheetTBCell
        
        cell.cellType = ConvertAudioType(rawValue: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectMediaCell(type: ConvertAudioType(rawValue: indexPath.row) ?? .aac)
        self.animationDismiss()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ConvertSheetTBCell.heightCell
    }
    
}

