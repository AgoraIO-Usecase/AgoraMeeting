//
//  VideoCell1.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/2.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

protocol VideoCellDelegate: NSObject {
    func videoCell(cell: VideoCell, tapType: VideoCell.SheetAction, info: VideoCell.Info)
}


class VideoCell: UICollectionViewCell {
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var meunButton: UIButton!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var videoMaskImageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var hostImageView: UIImageView!
    @IBOutlet weak var videoMaskImageViewMini: UIImageView!
    @IBOutlet weak var audioButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var headImageViewHeightConstraint: NSLayoutConstraint!
    let displayLabel = UILabel()
    private var info: Info?
    let sheetView = VideoCellSheetView()
    var sheetViewHeightConstraint: NSLayoutConstraint?
    weak var delegate: VideoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        meunButton.isSelected = false
        sheetView.isHidden = true
    }
    
    func setup() {
        
        displayLabel.text = NSLocalizedString("ui_t2", comment: "")
        displayLabel.font = UIFont.systemFont(ofSize: 9)
        displayLabel.textColor = .white
        sheetView.isHidden = true
        contentView.addSubview(sheetView)
        contentView.addSubview(displayLabel)
        
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        sheetView.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        sheetView.topAnchor.constraint(equalTo: meunButton.bottomAnchor).isActive = true
        sheetViewHeightConstraint = sheetView.heightAnchor.constraint(equalToConstant: 179)
        sheetViewHeightConstraint?.isActive = true
        
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        displayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        displayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    func commonInit() {
        sheetView.delegate = self
    }
    
    @IBAction func buttonTap(_ sender: UIButton) {
        if sender == upButton {
            delegate?.videoCell(cell: self, tapType: .upButton, info: info!)
        }
        
        if sender == meunButton {
            meunButton.isSelected = !meunButton.isSelected
            if meunButton.isSelected {
                sheetView.setInfos(infos: info!.sheetInfos)
            }
            sheetView.isHidden = !meunButton.isSelected
            
        }
    }
    
    func config(info: Info) {
        self.info = info
        let imageName = info.enableAudio ? "state-unmute" : "state-mute"
        audioImageView.image = UIImage(named: imageName)
        audioButtonLeadingConstraint.constant = info.isHost ? 21 : 2
        nameLabel.text = info.name
        upButton.isSelected = info.isUp
        meunButton.isHidden = !info.showMeunButton
        headImageView.isHidden = !info.showHeadImage
        headImageView.image = UIImage(named: info.headImageName)
        hostImageView.isHidden = !info.isHost
        displayLabel.isHidden = true
        videoMaskImageView.isHidden = false
        videoMaskImageViewMini.isHidden = true
        videoView.isHidden = info.showHeadImage
        contentView.layoutIfNeeded()
        
        headImageView.layer.cornerRadius = headImageViewWidthConstraint.constant/2
        headImageView.layer.masksToBounds = true
        
        if info.sheetInfos.count == 0 {
            meunButton.isHidden = true
        }
    }

    var getInfo: Info? {
        return info
    }
}

extension VideoCell {
    enum SheetAction {
        /** 置顶 */
        case upButton
        /** 静音 */
        case closeAudio
        /** 关闭视频 */
        case closeVideo
        /** 移除房间 */
        case remove
        /** 设置为主持人 */
        case setHost
        /** 成为主持人 */
        case becomHost
        /** 放弃主持人 */
        case abandonHost
    }
    
    struct Info: Equatable {
        let isHost: Bool
        let enableAudio: Bool
        let name: String
        let isUp: Bool
        var showMeunButton: Bool
        let headImageName: String
        let showHeadImage: Bool
        let isMe: Bool
        let streamId: String
        let sheetInfos: [VideoCellSheetView.Info]
        let userId: String
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.isHost == rhs.isHost &&
                lhs.enableAudio == rhs.enableAudio &&
                lhs.name == rhs.name &&
                lhs.isUp == rhs.isUp &&
                lhs.showMeunButton == rhs.showMeunButton &&
                lhs.headImageName == rhs.headImageName &&
                lhs.showHeadImage == rhs.showHeadImage &&
                lhs.isMe == rhs.isMe &&
                lhs.streamId == rhs.streamId &&
                lhs.sheetInfos == rhs.sheetInfos &&
                lhs.userId == rhs.userId
        }
        
    }
}

extension VideoCell: VideoCellSheetViewDelegate {
    func videoCellSheetViewShouldUpdateHeight(height: CGFloat) {
        sheetViewHeightConstraint?.constant = height
    }
    
    func buttonDidTap(info: VideoCellSheetView.Info) {
        switch info.actionType {
        case .closeAudio:
            delegate?.videoCell(cell: self, tapType: .closeAudio, info: self.info!)
            break
        case .closeVideo:
            delegate?.videoCell(cell: self, tapType: .closeVideo, info: self.info!)
            break
        case .remove:
            delegate?.videoCell(cell: self, tapType: .remove, info: self.info!)
            break
        case .becomeHost:
            delegate?.videoCell(cell: self, tapType: .becomHost, info: self.info!)
            break
        case .setAsHost:
            delegate?.videoCell(cell: self, tapType: .setHost, info: self.info!)
            break
        case .abandonHost:
            delegate?.videoCell(cell: self, tapType: .abandonHost, info: self.info!)
            break
        }
    }
}
