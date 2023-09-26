//
//  TransparentBottomSheetController.swift
//  InstagramClone
//
//  Created by Đức Anh Trần on 22/05/2023.
//

import UIKit

// MARK: - BottomSheetType
enum BottomSheetType {
	case fill
	case float(leftSpacing: CGFloat, rightSpacing: CGFloat, bottomSpacing: CGFloat)

	var spacingFromLeft: CGFloat {
		switch self {
			case .fill:
				return .zero
			case .float(let leftSpacing, _, _):
				return leftSpacing
		}
	}

	var spacingFromRight: CGFloat {
		switch self {
			case .fill:
				return .zero
			case .float(_, let rightSpacing, _):
				return rightSpacing
		}
	}

	var spacingFromBottom: CGFloat {
		switch self {
			case .fill:
				return .zero
			case .float(_, _, let bottomSpacing):
				return bottomSpacing
		}
	}
}

// MARK: - BottomSheetHeight
enum BottomSheetHeight {
	case medium
	case large
	case aspect(_ aspect: CGFloat)
	case fixed(_ height: CGFloat)

	var preferedHeight: CGFloat {
		switch self {
			case .medium:
				return UIScreen.main.bounds.height / 2
			case .large:
				guard let window = UIWindow.keyWindow else { return .zero }
				let safeFrame = window.safeAreaLayoutGuide.layoutFrame
				let topInset = safeFrame.minY
				return window.bounds.height - topInset
			case .aspect(let aspect):
				guard let window = UIWindow.keyWindow else { return .zero }
				let height = window.bounds.height * aspect
				return height
			case .fixed(let height):
				return height
		}
	}
}

// MARK: - BottomSheetCorner
enum BottomSheetCorner {
	case top(radius: CGFloat)
	case bottom(radius: CGFloat)
	case both(radius: CGFloat)

	var preferedRadius: CGFloat {
		switch self {
			case .top(let radius):
				return radius
			case .bottom(let radius):
				return radius
			case .both(let radius):
				return radius
		}
	}
}

// MARK: - TransparentBottomSheetController
class TransparentBottomSheetController: UIViewController {

    // MARK: - Public properties
    var rootView: UIView {
        fatalError("Subclass must override this property")
    }

	var sheetType: BottomSheetType {
		return .fill
	}

	var cornerRadius: BottomSheetCorner {
		return .top(radius: 20)
	}

	var sheetHeight: BottomSheetHeight {
		return .medium
	}

	var isGrabberVisible: Bool {
		return false
	}

	var animationInterval: TimeInterval {
		return 0.25
	}

	var dimmingColor: UIColor {
		return UIColor.black.withAlphaComponent(0.5)
	}

    // MARK: - Public methods
	@objc func didTapDimmingView() {
		removeSheet()
	}

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        let translate = gesture.translation(in: gestureView.superview).y
        let velocity = gesture.velocity(in: gestureView.superview).y
        let translatedFromOrigin = gestureView.center.y - self.originCenter.y
        let progress = translatedFromOrigin / gestureView.bounds.height

		switch gesture.state {
			case .began:
				self.originCenter = gestureView.center

			case .changed:
				if (velocity <= 0 && translatedFromOrigin <= 0) {
					gestureView.center.y = gestureView.center.y + translate / 20
				} else {
					gestureView.center.y = gestureView.center.y + translate
					dimmingView.alpha = 1 - progress
				}
				gesture.setTranslation(.zero, in: gestureView.superview)

			case .ended, .cancelled:
				if velocity > 1200 {
					removeSheet()
				} else if progress > 0.7 {
					removeSheet()
				} else {
					UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
						gestureView.center = self.originCenter
						self.dimmingView.alpha = 1
					}
				}

			default:
				break
		}
    }

	func showSheet(keyboardHeight: CGFloat = 0, duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
		self.rootViewTopConstraint.constant = -(keyboardHeight + sheetHeight.preferedHeight + spacingFromBottom)
        UIView.animate(withDuration: animationInterval, delay: 0, options: [.curveEaseOut]) {
			self.dimmingView.backgroundColor = self.dimmingColor
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }

    func removeSheet(duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        self.rootViewTopConstraint.constant = 0
        UIView.animate(withDuration: animationInterval, delay: 0, options: [.curveEaseOut]) {
            self.dimmingView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
            completion?()
        }
    }

	// MARK: - Private properties
	private var dimmingView: UIView!
	private var grabberView: UIView!
	private var rootViewTopConstraint: NSLayoutConstraint!
	private var rootViewHeightConstraint: NSLayoutConstraint!
	private var originCenter: CGPoint = .zero

	private var spacingFromLeft: CGFloat {
		sheetType.spacingFromLeft
	}

	private var spacingFromRight: CGFloat {
		sheetType.spacingFromRight
	}

	private var spacingFromBottom: CGFloat {
		sheetType.spacingFromBottom
	}

	// MARK: - Life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		dimmingView = UIView()
		grabberView = UIView()

		rootView.addSubview(grabberView)
		view.addSubview(dimmingView)
		view.addSubview(rootView)

		setupDimmingView()
		setupRootView()
		setupGrabberView()
		setupConstraints()
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

    // MARK: - Setup
    func setupConstraints() {
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        rootView.translatesAutoresizingMaskIntoConstraints = false

        switch sheetType {
            case .fill:
                rootViewHeightConstraint = rootView.heightAnchor.constraint(equalTo: view.heightAnchor)
            case .float:
				rootViewHeightConstraint = rootView.heightAnchor.constraint(equalToConstant: sheetHeight.preferedHeight)
        }
		rootViewTopConstraint = rootView.topAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            grabberView.topAnchor.constraint(equalTo: rootView.topAnchor, constant: 10),
            grabberView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 36),
            grabberView.heightAnchor.constraint(equalToConstant: 4),

            dimmingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            dimmingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            rootView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: spacingFromLeft),
            rootView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -spacingFromRight),
            rootViewHeightConstraint,
            rootViewTopConstraint
        ])
    }

    private func setupGrabberView() {
        grabberView.backgroundColor = .systemGray
        grabberView.layer.cornerRadius = 2
        grabberView.isHidden = !isGrabberVisible
    }

    private func setupDimmingView() {
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.isUserInteractionEnabled = true
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDimmingView)))
    }

    private func setupRootView() {
        let corner: CGFloat
        switch cornerRadius {
            case .top(let radius):
				corner = radius
                rootView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .bottom(let radius):
				corner = radius
                rootView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .both(let radius):
				corner = radius
                rootView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                                .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        rootView.layer.cornerRadius = corner
        rootView.clipsToBounds = true
        rootView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
    }
}
