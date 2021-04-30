//
//  MemberSheetVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/4/13.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import Presentr

class MemberSheetVC: UIViewController {
    typealias Action = MemberSheetView.Action
    private let contentView = MemberSheetView()
    private var presenter: Presentr?
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        commonInit()
    }

    private func setup() {
        contentView.setupLayout()
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: contentView.getHeight).isActive = true
    }
    
    private func commonInit() {
        let itemViews = contentView.getActionViews()
        for view in itemViews {
            let selector = view.action == .default ? #selector(buttonTap(button:)) : #selector(cancleButtonTap(button:))
            view.button.addTarget(self, action: selector, for: .touchUpInside)
        }
    }
    
    func addAction(_ action: Action) {
        contentView.actions.insert(action, at: 0)
    }
    
    func set(title: String, image: UIImage) {
        contentView.setTop(title: title, image: image)
    }
    
    var actions: [Action] {
        return contentView.actions
    }
    
    @objc func buttonTap(button: UIButton) {
        let action = contentView.getAction(button: button)
        dismiss(animated: true) {
            action?.handler?()
        }
    }
    
    @objc func cancleButtonTap(button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    public func show(in vc: UIViewController) {
        let p = CGPoint(x: 0, y: Int(Float(UIScreen.height - contentView.getHeight)))
        presenter = Presentr(presentationType: .custom(width: .full,
                                                       height: .custom(size: Float(contentView.getHeight)),
                                                       center: .customOrigin(origin: p)))
        vc.customPresentViewController(presenter!, viewController: self, animated: true, completion: nil)
    }

}
