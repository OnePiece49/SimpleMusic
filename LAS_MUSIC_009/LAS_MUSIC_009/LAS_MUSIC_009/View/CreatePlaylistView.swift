//
//  CreatePlaylistController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 16/08/2023.
//

import UIKit

protocol CreatePlaylistViewDelegate: AnyObject {
	func didTapOkButton(with name: String, option: CreatePlaylistView.Option)
}


class CreatePlaylistView: UIView {

	enum Option {
		case create, rename

		var title: String {
			switch self {
				case .create: return "CREATE PLAYLIST"
				case .rename: return "RENAME PLAYLIST"
			}
		}
	}

	var option: Option = .create {
		didSet { titleLabel.text = option.title }
	}
	weak var delegate: CreatePlaylistViewDelegate?

	//MARK: - UI components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .fontRailwayBold(14)
        label.textColor = UIColor(rgb: 0xEEEEEE)
        return label
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0x71737B)
        return view
    }()
    
    private lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false

        tf.font = .fontRailwayRegular(12)
        tf.textColor = .white //UIColor(rgb: 0x71737B)
		tf.attributedPlaceholder = NSAttributedString(string: "Enter your playlist name", attributes: [.font: UIFont.fontRailwayRegular(12), .foregroundColor: UIColor(rgb: 0x71737B)])
		return tf
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor(rgb: 0xF4FE88), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .fontRailwayBold(14)
        button.addTarget(self, action: #selector(handleCancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        button.setTitleColor(UIColor(rgb: 0x20242F), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .fontRailwayBold(14)
        button.backgroundColor = UIColor(rgb: 0xF4FE88)
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleOKButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0x292D39)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(usernameTextField)
        view.addSubview(dividerView)
        view.addSubview(cancelButton)
        view.addSubview(okButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 13),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            usernameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 29),
            usernameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            usernameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            
            dividerView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 1),
            dividerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            dividerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            dividerView.heightAnchor.constraint(equalToConstant: 0.5),
            
            cancelButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 24),
            cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            
            okButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 24),
            okButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
        ])
        okButton.setDimensions(width: 93, height: 31)
        cancelButton.setDimensions(width: 93, height: 31)
        return view
    }()
    
    //MARK: - View Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    func configureUI() {
        backgroundColor = .black.withAlphaComponent(0.3)
        
        addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
			containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
        ])
        containerView.setDimensions(width: 223, height: 154)
        alpha = 0
		isHidden = true
    }
    
    func show() {
		self.isHidden = false
		self.usernameTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1
        }
    }
    
    func dismiss() {
		UIView.animate(withDuration: 0.1) {
			self.alpha = 0
		} completion: { _ in
			self.isHidden = true
		}
        self.usernameTextField.text = ""
		self.endEditing(true)
    }

    //MARK: - Selectors
    @objc func handleCancelButtonTapped() {
        dismiss()
    }
    
    @objc func handleOKButtonTapped() {
		self.delegate?.didTapOkButton(with: self.usernameTextField.text ?? "", option: option)
        dismiss()
    }
    
}
