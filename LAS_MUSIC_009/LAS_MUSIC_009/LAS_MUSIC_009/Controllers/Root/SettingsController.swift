//
//  SettingsController.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 13/08/2023.
//

import UIKit
import MessageUI

enum SettingsOption: Int, CaseIterable {
	case notification
	case shareApp
	case rateApp
	case service
	case contact

	var title: String {
		switch self {
			case .notification: return "Notification"
			case .shareApp: return "Share App"
			case .rateApp: return "Rate App"
			case .service: return "Term of Service"
			case .contact: return "Contact Us"
		}
	}

	var iconName: String {
		switch self {
			case .notification: return AssetConstant.ic_notification
			case .shareApp: return AssetConstant.ic_share_app
			case .rateApp: return AssetConstant.ic_rate_app
			case .service: return AssetConstant.ic_term_of_service
			case .contact: return AssetConstant.ic_contact_us
		}
	}
}

class SettingsController: BaseController {

    // MARK: - Properties
	private var turnOnNotification: Bool = false

    // MARK: - UIComponent
	private let titleLbl: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 1
		label.font = .fontRailwayBold(22)
		label.textColor = UIColor(rgb: 0xEEEEEE)
		label.text = "Settings"
		return label
	}()

	private let settingTbv: UITableView = {
		let tbv = UITableView(frame: .zero, style: .plain)
		tbv.translatesAutoresizingMaskIntoConstraints = false
		return tbv
	}()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		setupConstraints()
		setupTBView()
    }
    
	private func setupConstraints() {
		view.addSubview(titleLbl)
		view.addSubview(settingTbv)

		// title label
		titleLbl.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: isIphone ? 14 : 25)
		titleLbl.centerX(centerX: view.centerXAnchor)

		// setting table view
		settingTbv.anchor(leading: view.leadingAnchor,
						  top: titleLbl.bottomAnchor, paddingTop: 20,
						  trailing: view.trailingAnchor,
						  bottom: view.bottomAnchor)
	}

	private func setupTBView() {
		settingTbv.backgroundColor = .primaryBackgroundColor
		settingTbv.separatorStyle = .none
		settingTbv.isScrollEnabled = false
		settingTbv.delegate = self
		settingTbv.dataSource = self
		settingTbv.register(SettingsItemTBCell.self, forCellReuseIdentifier: SettingsItemTBCell.cellId)
	}
}

// MARK: - Method
extension SettingsController {
	private func rateApp() {
		guard let url = URL(string: "itms-apps://itunes.apple.com/app/" + "appId") else { return}
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

	private func shareApp(cell: UITableViewCell) {
		let firstItem = "Files LasBom App"

		// Setting url
		let secondItem : NSURL = NSURL(string: "http://your-url.com/")!

		// If you want to use an image
		let activityItems: [Any] = [firstItem, secondItem]
		let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = cell
		activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
		activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)

		// Pre-configuring activity items
		if #available(iOS 13.0, *) {
			activityViewController.activityItemsConfiguration = [
				UIActivity.ActivityType.message
			] as? UIActivityItemsConfigurationReading
		}

		activityViewController.excludedActivityTypes = [
			UIActivity.ActivityType.postToWeibo,
			UIActivity.ActivityType.print,
			UIActivity.ActivityType.assignToContact,
			UIActivity.ActivityType.saveToCameraRoll,
			UIActivity.ActivityType.addToReadingList,
			UIActivity.ActivityType.postToFlickr,
			UIActivity.ActivityType.postToVimeo,
			UIActivity.ActivityType.postToTencentWeibo,
			UIActivity.ActivityType.postToFacebook
		]

		if #available(iOS 13.0, *) {
			activityViewController.isModalInPresentation = true
		}

		self.present(activityViewController, animated: true, completion: nil)
	}

	private func sendFeedback(controller: UIViewController) {
		let emailSupport = ""

		if MFMailComposeViewController.canSendMail() {
			let composeVC = MFMailComposeViewController()
			composeVC.mailComposeDelegate = self
			composeVC.setToRecipients([emailSupport])
			controller.present(composeVC, animated: true, completion: nil)

		} else {
			let alert = UIAlertController(title: "Notification", message: "You have not set up an email.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
			if let popover = alert.popoverPresentationController {
				popover.sourceView = controller.view
				popover.sourceRect = controller.view.bounds
			}
			controller.present(alert, animated: true, completion: nil)
		}
	}

	private func termOfPolicy() {
		guard let url = URL(string: "https://www.google.com.vn/") else { return }
		UIApplication.shared.open(url)
	}
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingsController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}
}

// MARK: - UITableViewDataSource
extension SettingsController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return SettingsOption.allCases.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SettingsItemTBCell.cellId,
												 for: indexPath) as! SettingsItemTBCell
		cell.option = SettingsOption(rawValue: indexPath.row)
		cell.toggleSwitch(isOn: turnOnNotification)
		cell.selectionStyle = .none
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard let option = SettingsOption(rawValue: indexPath.row),
			  let cell = tableView.cellForRow(at: indexPath) as? SettingsItemTBCell else { return }

		switch option {
			case .notification:
				self.turnOnNotification.toggle()
				cell.toggleSwitch(isOn: turnOnNotification)
			case .shareApp:
				self.shareApp(cell: cell)
			case .rateApp:
				self.rateApp()
			case .service:
				self.termOfPolicy()
			case .contact:
				self.sendFeedback(controller: self)
		}
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return SettingsItemTBCell.cellHeight
	}
}
