//
//  ASCheckBoxAlertVC.swift
//  AgoraSceneUI
//
//  Created by ZYP on 2021/1/19.
//

import UIKit
import Presentr

public protocol ASCheckBoxAlertVCDelegate: NSObject {
    func checkBoxAlertVCDidTapSureButton(checkBoxSeleted: Bool, style: ASCheckBoxAlertVC.Style)
}

public class ASCheckBoxAlertVC: UIViewController {

    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let checkButton = UIButton()
    private let cancleButton = UIButton()
    private let sureButton = UIButton()
    private let presenter = Presentr(presentationType: .custom(width: .custom(size: 270), height: .custom(size: 164), center: .center))
    public weak var delegate: ASCheckBoxAlertVCDelegate?
    private var style: Style = .audio
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        let blur = UIBlurEffect(style: .extraLight)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.layer.cornerRadius = 13
        effectView.layer.masksToBounds = true
        view.backgroundColor = .clear
        let line1 = UIView()
        let line2 = UIView()
        
        line1.backgroundColor = .gray
        line2.backgroundColor = .gray
        
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 18)
        titleLabel.textColor = UIColor(hex: 0x333333)
        
        detailLabel.font = .systemFont(ofSize: 15)
        detailLabel.textColor = UIColor(hex: 0x333333)
        
        let buttonBgImage = UIImage().coloredImage(color: UIColor.gray.withAlphaComponent(0.15))
        cancleButton.setTitle(NSLocalizedString("mem_t3", comment: ""), for: .normal)
        cancleButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17)
        cancleButton.setTitleColor(UIColor(hex: 0x1677ff), for: .normal)
        cancleButton.setBackgroundImage(buttonBgImage, for: .highlighted)
        cancleButton.adjustsImageWhenHighlighted = true;
        cancleButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        
        sureButton.setTitle(NSLocalizedString("meeting_t56", comment: ""), for: .normal)
        sureButton.setTitleColor(UIColor(hex: 0x1677ff), for: .normal)
        sureButton.setBackgroundImage(buttonBgImage, for: .highlighted)
        sureButton.adjustsImageWhenHighlighted = true;
        sureButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        
        let imageNormal = Bundle.main.image(name: "Checkbox")
        let imageSelected = Bundle.main.image(name: "Checkboxblue")
        checkButton.setImage(imageNormal, for: .normal)
        checkButton.setImage(imageSelected, for: .selected)
        checkButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        
        view.addSubview(effectView)
        view.addSubview(line1)
        view.addSubview(line2)
        view.addSubview(titleLabel)
        view.addSubview(detailLabel)
        view.addSubview(checkButton)
        view.addSubview(cancleButton)
        view.addSubview(sureButton)
        
        
        effectView.translatesAutoresizingMaskIntoConstraints = false
        line1.translatesAutoresizingMaskIntoConstraints = false
        line2.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        cancleButton.translatesAutoresizingMaskIntoConstraints = false
        sureButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([effectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     effectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     effectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     effectView.topAnchor.constraint(equalTo: view.topAnchor)])
        
        NSLayoutConstraint.activate([titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                                     titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        
        NSLayoutConstraint.activate([detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11),
                                     detailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 8)])
        
        NSLayoutConstraint.activate([checkButton.centerYAnchor.constraint(equalTo: detailLabel.centerYAnchor),
                                     checkButton.trailingAnchor.constraint(equalTo: detailLabel.leadingAnchor, constant: -2)])
        
        NSLayoutConstraint.activate([line1.heightAnchor.constraint(equalToConstant: 0.5),
                                     line1.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     line1.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     line1.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)])
        
        NSLayoutConstraint.activate([line2.widthAnchor.constraint(equalToConstant: 0.5),
                                     line2.topAnchor.constraint(equalTo: line1.bottomAnchor),
                                     line2.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     line2.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        
        NSLayoutConstraint.activate([cancleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     cancleButton.trailingAnchor.constraint(equalTo: line2.leadingAnchor),
                                     cancleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     cancleButton.topAnchor.constraint(equalTo: line1.bottomAnchor)])
        
        NSLayoutConstraint.activate([sureButton.leadingAnchor.constraint(equalTo: line2.trailingAnchor, constant: 0.2),
                                     sureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     sureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     sureButton.topAnchor.constraint(equalTo: line1.bottomAnchor)])
    }
    
    public func show(in vc: UIViewController, style: Style) {
        config(style: style)
        presenter.roundCorners = true
        let prensentAnimation = ASSystemAlertPrensentAnimation()
        let dismissAnimation = CrossDissolveAnimation(options: .normal(duration: 0.25))
        presenter.transitionType = .custom(prensentAnimation)
        presenter.dismissTransitionType = .custom(dismissAnimation)
        presenter.backgroundOpacity = 0.18
        presenter.backgroundTap = .noAction
        presenter.cornerRadius = 13
        vc.customPresentViewController(presenter, viewController: self, animated: true, completion: nil)
    }
    
    @objc func buttonTap(button: UIButton) {
        if button == checkButton {
            checkButton.isSelected = !checkButton.isSelected
        }
        else if button == cancleButton {
            dismiss(animated: true, completion: nil)
        }
        else {
            let selected = checkButton.isSelected
            let style = self.style
            dismiss(animated: true, completion: { [weak self]() in
                self?.delegate?.checkBoxAlertVCDidTapSureButton(checkBoxSeleted: selected, style: style)
            })
            
        }
    }
    
    func config(style: Style) {
        self.style = style
        titleLabel.text = style == .audio ? NSLocalizedString("meeting_t6", comment: "") : NSLocalizedString("meeting_t5", comment: "")
        detailLabel.text = style == .audio ? NSLocalizedString("meeting_t57", comment: "") : NSLocalizedString("meeting_t58", comment: "")
    }

}

extension ASCheckBoxAlertVC {
    public enum Style {
        case audio
        case video
    }
}

