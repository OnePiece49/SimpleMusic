//
//  PopoverCustomController.swift
//  Las_File_Offline_001
//
//  Created by Tiến Việt Trịnh on 30/07/2023.
//

import UIKit

/*
        --
        ||
        --
            (.)
            --------
            | View |
            --------
 
    EXP: TopLeft: (.) Là điểm xuất hiện, và nó sẽ mở rộng ra theo hướng topLeft
 */

enum PopoverDirection {
    case topLeft
    case topRight
    case botLeft
    case botRight
}


class PopoverCustomController: UIViewController {
    
    //MARK: - Properties
    let popoverSize: CGSize!
    let pointAppear: CGPoint!
    let popoverDirection: PopoverDirection
    
    //MARK: - UIComponent
    var popoverView: UIView {
        fatalError("Subclasses are not ovveride 'popoverView'")
    }
    
    private let shadowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    //MARK: - View Lifecycle
    init(popoverSize: CGSize,
         pointAppear: CGPoint,
         popoverDirection: PopoverDirection = .botLeft) {
        self.popoverSize = popoverSize
        self.pointAppear = pointAppear
        self.popoverDirection = popoverDirection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureUI()

    }
    
    func configureUI() {
    
        setupShadowView()
        configurePopover()
    }
    
}

//MARK: - Method
extension PopoverCustomController {
    
    //MARK: - Helpers
    private func configurePopover() {
        view.addSubview(popoverView)
        let xAppearce = pointAppear.x
        let yApperace = pointAppear.y
        let width = popoverSize.width
        let height = popoverSize.height
        
        
        popoverView.frame = .init(origin: .init(x: xAppearce, y: yApperace), size: .zero)
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseInOut) { [self] in
            switch popoverDirection {
            case .topLeft:
                popoverView.frame = .init(origin: .init(x: xAppearce - width, y: yApperace - height), size: popoverSize)
            case .topRight:
                popoverView.frame = .init(origin: .init(x: xAppearce, y: yApperace - height), size: popoverSize)
            case .botLeft:
                popoverView.frame = .init(origin: .init(x: xAppearce - width, y: yApperace), size: popoverSize)
            case .botRight:
                popoverView.frame = .init(origin: .init(x: xAppearce, y: yApperace), size: popoverSize)
            }
            
        }

        UIView.animate(withDuration: 0.3) {
            self.shadowView.alpha = 0.75
        }
    }
    
    private func setupShadowView() {
        view.addSubview(shadowView)
                
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: view.topAnchor),
            shadowView.leftAnchor.constraint(equalTo: view.leftAnchor),
            shadowView.rightAnchor.constraint(equalTo: view.rightAnchor),
            shadowView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.shadowView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                    action: #selector(animationDismiss)))
        self.shadowView.isUserInteractionEnabled = true
    }
    
    //MARK: - Selectors
    @objc func animationDismiss() {
        let xAppearce = pointAppear.x
        let yApperace = pointAppear.y
        
        UIView.animate(withDuration: 0.2) { [self] in
            popoverView.frame = .init(origin: .init(x: xAppearce, y: yApperace), size: .zero)
            shadowView.alpha = 0
            popoverView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        
    }
    
}

