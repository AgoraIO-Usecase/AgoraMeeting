//
//  MessageTopView.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/24.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

protocol MessageTopViewDelegate: NSObject {
    func messageTopViewDidSelectedTyep(type: MessageTopView.SelectedType)
}

class MessageTopView: UIView {
    let leftButton = UIButton()
    let rightButton = UIButton()
    let indicatedView = UIView()
    var centerXToLeft: NSLayoutConstraint?
    var centerXToRight: NSLayoutConstraint?
    weak var delegate: MessageTopViewDelegate?
    var selectedType = SelectedType.left
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        leftButton.setTitle(NSLocalizedString("msg_t5", comment: ""), for: .normal)
        leftButton.setTitleColor(.them(), for: .selected)
        leftButton.setTitleColor(UIColor(hex: 0x333333), for: .normal)
        leftButton.isSelected = true
        rightButton.setTitle(NSLocalizedString("msg_t6", comment: ""), for: .normal)
        rightButton.setTitleColor(.them(), for: .selected)
        rightButton.setTitleColor(UIColor(hex: 0x333333), for: .normal)
        
        indicatedView.backgroundColor = .them()
        
        
        
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        indicatedView.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(indicatedView)
        
        leftButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        leftButton.rightAnchor.constraint(equalTo: centerXAnchor).isActive = true
        leftButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        rightButton.leftAnchor.constraint(equalTo: centerXAnchor).isActive = true
        rightButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        rightButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rightButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        indicatedView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        indicatedView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        indicatedView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        centerXToLeft = indicatedView.centerXAnchor.constraint(equalTo: leftButton.centerXAnchor)
        centerXToRight = indicatedView.centerXAnchor.constraint(equalTo: rightButton.centerXAnchor)
        centerXToLeft?.isActive = true
        
        backgroundColor = .white
    }
    
    func commonInit() {
        leftButton.addTarget(self, action: #selector(buttonTap(btn:)), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(buttonTap(btn:)), for: .touchUpInside)
    }
    
    func setSelected(type: SelectedType) {
        if selectedType != type {
            selectedType = type
            if type == .left {
                UIView.animate(withDuration: 0.25) {
                    self.centerXToRight?.isActive = false
                    self.centerXToLeft?.isActive = true
                    self.layoutIfNeeded()
                } completion: { (_) in
                    self.leftButton.isSelected = !self.leftButton.isSelected
                    self.rightButton.isSelected = !self.rightButton.isSelected
                }
            }
            else {
                UIView.animate(withDuration: 0.25) {
                    self.centerXToLeft?.isActive = false
                    self.centerXToRight?.isActive = true
                    self.layoutIfNeeded()
                } completion: { (_) in
                    self.leftButton.isSelected = !self.leftButton.isSelected
                    self.rightButton.isSelected = !self.rightButton.isSelected
                }
            }
        }
    }
    
    @objc func buttonTap(btn: UIButton) {
        let type: SelectedType = btn == leftButton ? .left : .right
        setSelected(type: type)
        delegate?.messageTopViewDidSelectedTyep(type: type)
    }
    
    
}

extension MessageTopView {
    enum SelectedType {
        case left
        case right
    }
}
