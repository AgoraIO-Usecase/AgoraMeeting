//
//  MemberSheetView.swift
//  VideoConference
//
//  Created by ZYP on 2021/4/13.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

class MemberSheetView: UIView {
    var actions = [Action]()
    private let topView = TopView()
    private let itemHeight: CGFloat = 57
    private let lefRightPading: CGFloat = 9
    private let cancleTopGap: CGFloat = 8
    private let lineHeight: CGFloat = 1/UIScreen.main.scale
    private let cancleBottomGap: CGFloat = 8
    private var actionViews = [ItemView]()
    
    func setTop(title: String, image: UIImage) {
        topView.set(title: title)
        topView.set(image: image)
    }
    
    func setupLayout() {
        actionViews = actions.enumerated().map({ (index, action) -> ItemView in
            let view = ItemView(action: action.style, title: action.title)
            view.button.tag = index
            return view
        })
        
        setupCancleView()
        
        let actionViewsDefault = actionViews.filter({ $0.action == .default })
        let count = actionViewsDefault.count
        for i in 0..<count {
            let view = actionViewsDefault[i]
            setDefaultView(view: view, index: i)
        }
        
        setTopView(count: count)
    }
    
    private func setupCancleView() {
        guard let view = actionViews.filter({ $0.action == .cancel }).first else {
            return
        }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -1 * cancleBottomGap).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor, constant: lefRightPading).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor, constant: -1.0 *  lefRightPading).isActive = true
        view.heightAnchor.constraint(equalToConstant: itemHeight).isActive = true
    }
    
    private func setDefaultView(view: ItemView, index: Int) {
        let line = UIImageView()
        line.image = UIImage(named: "直线")
        addSubview(view)
        addSubview(line)
        view.translatesAutoresizingMaskIntoConstraints = false
        line.translatesAutoresizingMaskIntoConstraints = false
        
        let constant = cancleBottomGap + itemHeight + cancleTopGap + (CGFloat(index) * (itemHeight + lineHeight))
        view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -1 * constant).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor, constant: lefRightPading).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor, constant: -1.0 * lefRightPading).isActive = true
        view.heightAnchor.constraint(equalToConstant: itemHeight).isActive = true
        
        line.heightAnchor.constraint(equalToConstant: lineHeight).isActive = true
        line.leftAnchor.constraint(equalTo: leftAnchor, constant: lefRightPading).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor, constant: -1.0 *  lefRightPading).isActive = true
        line.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    private func setTopView(count: Int) {
        addSubview(topView)
        topView.translatesAutoresizingMaskIntoConstraints = false
        
        let constant = cancleBottomGap + itemHeight + cancleTopGap + (CGFloat(count) * (itemHeight + lineHeight))
        topView.leftAnchor.constraint(equalTo: leftAnchor, constant: lefRightPading).isActive = true
        topView.rightAnchor.constraint(equalTo: rightAnchor, constant: -1.0 *  lefRightPading).isActive = true
        topView.heightAnchor.constraint(equalToConstant: itemHeight).isActive = true
        topView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -1 * constant).isActive = true
    }
    
    func getActionViews() -> [ItemView] {
        return actionViews
    }
    
    func getAction(button: UIButton) -> Action? {
        let count = actions.count
        if button.tag < count {
            return actions[button.tag]
        }
        return nil
    }
    
    var getHeight: CGFloat {
        let cancleHeight = itemHeight + cancleTopGap + cancleBottomGap
        let count = actions.filter({ $0.style == .default }).count
        let other = CGFloat(count) * (itemHeight + lineHeight)
        let topHeight = itemHeight
        return cancleHeight + other + topHeight + safeAreaInsets.bottom
    }
}

extension MemberSheetView {
    
    class ItemView: UIView {
        typealias ActionBlock = Action.ActionBlock
        typealias ActionType = Action.Style
    
        let action: ActionType
        let button = UIButton()
        private let title: String
        
        required init(action: ActionType, title: String) {
            self.action = action
            self.title = title
            super.init(frame: .zero)
            setup()
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            let image = UIImage().coloredImage(color: .gray)
            button.setBackgroundImage(image, for: .highlighted)
            button.adjustsImageWhenHighlighted = true
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor(hex: 0x268CFF), for: .normal)
            
            switch action {
            case .cancel:
                backgroundColor = .white
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                break
            default:
                backgroundColor = UIColor.white.withAlphaComponent(0.85)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                break
            }
            
            addSubview(button)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            button.topAnchor.constraint(equalTo: topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        private func commonInit() {
            
        }
    }
    
    class TopView: UIView {
        // 2722.12
        private let imageView = UIImageView()
        private let titleLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            backgroundColor = UIColor.white.withAlphaComponent(0.85)
            titleLabel.font = UIFont.systemFont(ofSize: 18)
            titleLabel.textColor = UIColor(hex: 0x323C47)
            layer.cornerRadius = 8
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            layer.masksToBounds = true
            imageView.layer.cornerRadius = 16
            imageView.layer.masksToBounds = true
            addSubview(imageView)
            addSubview(titleLabel)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
            
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        }
        
        func set(title: String) {
            titleLabel.text = title
        }
        
        func set(image: UIImage) {
            imageView.image = image
        }
    }
}

extension MemberSheetView {
    struct Action {
        typealias ActionBlock = () -> ()
        
        let title: String
        let style: Style
        var handler: ActionBlock?
        
        enum Style {
            case cancel
            case `default`
        }
    }
}
