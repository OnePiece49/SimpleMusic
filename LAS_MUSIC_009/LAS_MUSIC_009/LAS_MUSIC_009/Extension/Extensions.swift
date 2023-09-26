//
//  Extensions.swift
//  LAS_MUSIC_009
//
//  Created by Tiến Việt Trịnh on 13/08/2023.
//

import UIKit
import AVFoundation
import RealmSwift
import Toast_Swift
import Photos


extension Notification.Name {
    static let updateLikeButtonToPlayerController =  Notification.Name("UpdateLikeButtonWhenLikesFromOtherControllers")
    static let updateLikeButtonToOtherControllers =  Notification.Name("UpdateLikeButtonWhenLikesFromPlayerController")
    static let musicReadyToPlay = Notification.Name("musicIsReadyToPlay")
    static let avplayerVCDeinit = Notification.Name("ResetCommander")
}

extension UIDevice {
    var is_iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}

extension CMTime {
    func getTimeString() -> String? {
        let totalSeconds = CMTimeGetSeconds(self)
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else {
            return nil
        }
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds / 60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i",arguments: [hours, minutes, seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes, seconds])
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

	static func random() -> UIColor {
		return UIColor(red: .random(), green:.random(), blue:.random(), alpha: 1.0)
	}
    
    static let primaryYellow = UIColor(rgb: 0xCBFB5E)
	static let primaryBackgroundColor = UIColor(rgb: 0x1C1B1F)
	static let secondaryYellow = UIColor(rgb: 0xF4FE88)
}

extension UIViewController {
    static func loadController<T>() -> T {
        let identifier = String(describing: T.self)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
    
    var insetTop: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top ?? 0
            return topPadding
        }
        return 0
    }
    
    var insetBottom: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0
            return bottomPadding
        }
        return 0
    }
    
    func printPathRealm() {
        print("DEBUG: \(String(describing: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first))")
    }
    
    
    
}

extension UIView {
    func applyBlurBackground(style: UIBlurEffect.Style,
                             alpha: CGFloat = 1,
                             top: CGFloat = 0,
                             bottom: CGFloat = 0) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.alpha = alpha
        addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom),
        ])
    }
    
	func applyGradient(colours: [UIColor],
					   startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
					   endPoint: CGPoint = CGPoint(x: 1, y: 0.5))  {

        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    
	func displayToast(_ message: String, duration: TimeInterval = 2.5, position: ToastPosition = .top) {
        guard let window = UIWindow.keyWindow else { return }
        window.hideAllToasts()
        window.makeToast(message, duration: duration, position: position )
    }
    
    func generateThumbnail(path: URL, identifier: String,
                           completion: @escaping (_ thumbnail: UIImage?, _ identifier: String) -> Void) {
        
        let asset = AVURLAsset(url: path, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
        imgGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { _, image, _, _, _ in
            if let image = image {
                DispatchQueue.main.async {
                    completion(UIImage(cgImage: image), identifier)
                }
            }
        }
    }

	func roundCorners(radius: CGFloat) {
		layer.cornerRadius = radius
		clipsToBounds = true
		layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
	}
}

extension UIWindow {
    static var keyWindow: UIWindow? {
        // iOS13 or later
        if #available(iOS 13.0, *) {
            guard let scene = UIApplication.shared.connectedScenes.first,
                  let sceneDelegate = scene.delegate as? SceneDelegate else { return nil }
            return sceneDelegate.window
        } else {
            // iOS12 or earlier
            guard let appDelegate = UIApplication.shared.delegate else { return nil }
            return appDelegate.window ?? nil
        }
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


extension UIFont {
    
    static func fontRailwayBold(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Raleway-Bold", size: size)
    }
    
    static func fontRailwayMedium(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Raleway-Medium", size: size)
    }
    
    static func fontRailwaySemiBold(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Raleway-SemiBold", size: size)
    }

    
    static func fontRailwayRegular(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Raleway-Regular", size: size)
    }
    
    static func fontRobotoBold(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Raleway-Bold", size: size)
    }

    
    static func fontRobotoRegular(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "Roboto-Regular", size: size)
    }
    
}

extension UICollectionViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}

extension UITableViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}

extension TimeInterval {
    func getDuration() -> String? {
        CMTime(seconds: self, preferredTimescale: CMTimeScale(1.0)).getTimeString()
    }

	func toString() -> String {
		let time = NSInteger(self)

		let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
		let seconds = time % 60
		let minutes = (time / 60) % 60
		let hours = (time / 3600)

		return String(format: "%0.2d:%0.2d", minutes, seconds)

	}
}

extension URL {
    static func cache() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func document() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func createFolder(folderName: String) -> URL? {
        
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first else {return nil}
        let folderURL = documentDirectory.appendingPathComponent(folderName)
        
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                
                try fileManager.createDirectory(atPath: folderURL.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        return folderURL
        
    }
    
    static func importFolder() -> URL? {
        return self.createFolder(folderName: "Imported")
    }
    
    static func thumbnailFolder() -> URL? {
        return self.createFolder(folderName: "Thumbnail")
    }
    
    static func audioFolder() -> URL? {
        return self.createFolder(folderName: "Audio")
    }

	func appendingQuerys(_ items: [URLQueryItem]) -> URL? {
		guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

		// Create array of existing query items
		var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

		// Append the new query item in the existing query items array
		queryItems.append(contentsOf: items)

		// Append updated query items array in the url component object
		urlComponents.queryItems = queryItems

		// Returns the url from new url components
		return urlComponents.url
	}
}

extension String {
	var pathWithoutExtension: Self {
		let arr = self.split(separator: ".")
		var result: String = ""

		for (index, subString) in arr.enumerated() {
			if index == arr.count - 1 { break }
			result.append(String(subString))
		}

		return result
	}
    
    static func getSizeString(text: String, font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        return size
    }
}

extension PHAsset {
    
    var getImageMaxSize : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        imageManager.requestImage(for: self, targetSize: CGSize.init(width: 720, height: 1080), contentMode: .aspectFit, options: option, resultHandler: { image, _ in
            thumbnail = image!
        })
        return thumbnail
    }
    
    
    var getImageThumb : UIImage {
        var thumbnail = UIImage()
        let imageManager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        
        imageManager.requestImage(for: self, targetSize: CGSize.init(width: 400, height: 400), contentMode: .aspectFit, options: option, resultHandler: { image, _ in
            guard let image = image else {return}
            thumbnail = image
        })
        return thumbnail
    }
    
    var originalFilename: String? {
        return PHAssetResource.assetResources(for: self).first?.originalFilename
    }
    var originalName: String? {
        let str = PHAssetResource.assetResources(for: self).first?.originalFilename.dropLast(4)
        return "\(str ?? "Video")"
    }
    
    func getDuration(videoAsset: PHAsset?) -> String {
        guard let asset = videoAsset else { return "00:00" }
        let duration: TimeInterval = asset.duration
        let s: Int = Int(duration) % 60
        let m: Int = Int(duration) / 60
        let formattedDuration = String(format: "%02d:%02d", m, s)
        return formattedDuration
    }
}


extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}

extension List {
	func toArray<T>(ofType: T.Type) -> [T] {
		var array = [T]()
		for i in 0 ..< count {
			if let result = self[i] as? T {
				array.append(result)
			}
		}

		return array
	}
}

// Constraints
extension UIView {
	func pinToView(_ view: UIView) {
		translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			leadingAnchor.constraint(equalTo: view.leadingAnchor),
			topAnchor.constraint(equalTo: view.topAnchor),
			trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	func setDimensions(width: CGFloat, height: CGFloat) {
		translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			widthAnchor.constraint(equalToConstant: width),
			heightAnchor.constraint(equalToConstant: height),
		])
	}

	func setDimension(multiplier: CGFloat) {
		translatesAutoresizingMaskIntoConstraints = false
		widthAnchor.constraint(equalTo: heightAnchor, multiplier: multiplier).isActive = true
	}

	func anchor(leading: NSLayoutXAxisAnchor? = nil, paddingLeading: CGFloat = 0,
				top: NSLayoutYAxisAnchor? = nil, paddingTop : CGFloat = 0,
				trailing: NSLayoutXAxisAnchor? = nil, paddingTrailing: CGFloat = 0,
				bottom : NSLayoutYAxisAnchor? = nil, paddingBottom : CGFloat = 0,
				width: CGFloat? = nil, height: CGFloat? = nil){

		translatesAutoresizingMaskIntoConstraints = false

		if let leading = leading {
			leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
		}

		if let top = top {
			topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
		}

		if let trailing = trailing {
			trailingAnchor.constraint(equalTo: trailing, constant: paddingTrailing).isActive = true
		}

		if let bottom = bottom {
			bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
		}

		if let width = width {
			widthAnchor.constraint(equalToConstant: width).isActive = true
		}

		if let height = height {
			heightAnchor.constraint(equalToConstant: height).isActive = true
		}
	}

	func centerX(centerX: NSLayoutXAxisAnchor, paddingX: CGFloat = 0)  {
		translatesAutoresizingMaskIntoConstraints = false
		centerXAnchor.constraint(equalTo: centerX , constant: paddingX).isActive = true
	}

	func centerY(centerY: NSLayoutYAxisAnchor, paddingY: CGFloat = 0)  {
		translatesAutoresizingMaskIntoConstraints = false
		centerYAnchor.constraint(equalTo: centerY , constant: paddingY).isActive = true
	}

	func center(centerX: NSLayoutXAxisAnchor?, centerY: NSLayoutYAxisAnchor?)  {
		translatesAutoresizingMaskIntoConstraints = false
		if let centerX = centerX {
			self.centerX(centerX: centerX)
		}

		if let centerY = centerY {
			self.centerY(centerY: centerY)
		}
	}
}

extension CGFloat {
	static func random() -> CGFloat {
		return CGFloat(arc4random()) / CGFloat(UInt32.max)
	}
}

extension Array where Element == UIColor {
	static func generateRandomColors(count: Int) -> [UIColor] {
		var arr = [UIColor]()
		for _ in 0..<count {
			arr.append(UIColor.random())
		}
		return arr
	}
}
