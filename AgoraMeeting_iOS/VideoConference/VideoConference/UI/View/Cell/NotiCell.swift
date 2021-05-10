//
//  NotiCell.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/23.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

protocol NotiCellDelegate: NSObject {
    func notiCellDidTapButton(info: NotiCell.Info)
}

class NotiCell: UITableViewCell {

    private let timeLabel = UILabel()
    private let titleLabel = UILabel()
    private let button = UIButton()
    private let bgView = UIView()
    private var info: Info?
    private var buttonConstranit: NSLayoutConstraint?
    private var bgViewTopConstranit: NSLayoutConstraint?
    private var timeLabelTopConstranit: NSLayoutConstraint?
    private var titleLabelWidthConstranit: NSLayoutConstraint?
    weak var delegate: NotiCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        backgroundColor = .clear
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        bgView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor  = UIColor.text()
        bgView.backgroundColor = .white
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 8
        button.backgroundColor = .them()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 2
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        
        contentView.addSubview(bgView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(button)
        
        
        timeLabelTopConstranit = timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        timeLabelTopConstranit?.isActive = true
        timeLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        titleLabel.numberOfLines = 0
        
        bgViewTopConstranit = bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10+17+3)
        bgViewTopConstranit?.isActive = true
        bgView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bgView.rightAnchor.constraint(equalTo: button.rightAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
        titleLabelWidthConstranit = titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.width - 115)
        titleLabelWidthConstranit?.isActive = true
        
        button.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 10).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        buttonConstranit = button.widthAnchor.constraint(equalToConstant: 80)
        buttonConstranit?.isActive = true
        
    }
    
    func setInfo(info: Info) {
        self.info = info
        
        titleLabel.text = info.msg
        titleLabel.textColor = info.bgClolorType == .white ? .text() : .white
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.text = info.time
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        timeLabel.isHidden = !info.showTime
        
        let buttonTitle = info.timeCount ?? 0 > 0 ? "\(info.buttonTitle ?? "")(\(Int(info.timeCount!)))" : info.buttonTitle
        button.setTitle(buttonTitle, for: .normal)
        button.setTitle(buttonTitle, for: .disabled)
        button.isHidden = info.buttonTitle == nil
        button.isEnabled = info.buttonEnable
        button.backgroundColor = info.buttonEnable ? .them() : .gray
        bgView.backgroundColor = info.bgClolorType == .white ? .white : UIColor(white: 0, alpha: 0.6)
        titleLabelWidthConstranit?.constant = info.buttonEnable ? UIScreen.width - 115 : UIScreen.width - 50
        if info.showTime {
            if info.isFirstCell {
                timeLabelTopConstranit?.constant = 10
                bgViewTopConstranit?.constant = 10+17+3
            }
            else {
                bgViewTopConstranit?.constant = 10+17+3 + 25
                timeLabelTopConstranit?.constant = 10 + 25
            }
        }
        else {
            bgViewTopConstranit?.constant = 10
            timeLabelTopConstranit?.constant = 10
        }
        
        if let buttonTitle = buttonTitle {
            let size = buttonTitle.agoraKitSize(font: button.titleLabel!.font, height: 15)
            buttonConstranit?.constant = size.width + 20
//            bgViewHeightConstranit?.constant = 62
        }
        else {
            buttonConstranit?.constant = 0.1
//            bgViewHeightConstranit?.constant = 40
        }
        contentView.layoutIfNeeded()
    }
    
    @objc func buttonTap() {
        if let temp = info {
            delegate?.notiCellDidTapButton(info: temp)
        }
    }

}

extension NotiCell {
    struct Info {
        let msg: String
        let buttonTitle: String?
        let buttonEnable: Bool
        let bgClolorType: BbColorType
        var timeCount: TimeInterval?
        let time: String
        let typeValue: Int
        let targetUserId: String
        var showTime = true
        let timeStamp: TimeInterval
        var isFirstCell = false
        
        enum BbColorType {
            case gra
            case white
        }
        
        /// init for tips
        init(msg: String,
             time: String,
             typeValue: Int,
             timeStamp: TimeInterval) {
            self.msg = msg
            self.bgClolorType = .gra
            self.buttonTitle = nil
            self.timeCount = nil
            self.time = time
            self.buttonEnable = false
            self.typeValue = typeValue
            self.targetUserId = ""
            self.timeStamp = timeStamp
        }
        
        /// init for button
        init(msg: String,
             buttonTitle: String,
             buttonEnable: Bool,
             time: String,
             typeValue: Int,
             timeStamp: TimeInterval) {
            self.msg = msg
            self.bgClolorType = .white
            self.buttonTitle = buttonTitle
            self.timeCount = nil
            self.time = time
            self.buttonEnable = buttonEnable
            self.typeValue = typeValue
            self.targetUserId = ""
            self.timeStamp = timeStamp
        }
        
        /// init for time count
        init(msg: String,
             buttonTitle: String,
             buttonEnable: Bool,
             timeCount: TimeInterval?,
             time: String,
             typeValue: Int,
             targetUserId: String,
             timeStamp: TimeInterval) {
            self.msg = msg
            self.bgClolorType = .white
            self.buttonTitle = buttonTitle
            self.timeCount = timeCount
            self.time = time
            self.buttonEnable = buttonEnable
            self.typeValue = typeValue
            self.targetUserId = targetUserId
            self.timeStamp = timeStamp
        }
        
        var cellHeight: CGFloat {
            let size = msg.agoraKitSize(font: UIFont.systemFont(ofSize: 14), width: UIScreen.width * 10, height: 17)
            let len = size.width
            let maxCellWidth = buttonEnable ? UIScreen.width - 115 : UIScreen.width - 50
            let ex: CGFloat = len / maxCellWidth * 14
            if buttonTitle != nil {
                if showTime {
                    if isFirstCell {
                        return 92 + ex
                    }
                    else {
                        return 92 + 15 + 10 + ex
                    }
                }
                else {
                    return 62 + 10 + ex
                }
            }
            else {
                if showTime {
                    if isFirstCell {
                        
                        return 70 + ex
                    }
                    else {
                        return 95 + ex
                    }
                }
                else {
                    
                    return 50 + ex
                }
            }
            
        }
    }
}
