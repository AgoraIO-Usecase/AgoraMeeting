//
//  VideoCellMini.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/2.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit



class VideoCellMini: UICollectionViewCell {
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
    
    var sheetViewHeightConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setup() {
        
        displayLabel.text = NSLocalizedString("ui_t2", comment: "")
        displayLabel.font = UIFont.systemFont(ofSize: 9)
        displayLabel.textColor = .white
        contentView.addSubview(displayLabel)
        
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        displayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        displayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    func commonInit() {
        
    }
    
    func config(info: Info) {
        self.info = info
        hostImageView.isHidden = info.type == .video ? !info.isHost : true
        audioImageView.isHidden = info.type != .video
        nameLabel.isHidden = info.type != .video
        let imageName = info.enableAudio ? "state-unmute" : "state-mute"
        audioImageView.image = UIImage(named: imageName)
        audioButtonLeadingConstraint.constant = info.isHost ? 21 : 5
        nameLabel.text = info.name
        headImageView.image = UIImage(named: info.headImageName)
        
        switch info.type {
        case .video:
            videoView.isHidden = info.showHeadImage
            displayLabel.text = NSLocalizedString("ui_t2", comment: "")
            displayLabel.isHidden = !info.hasDisplayInMainScreen
            headImageView.isHidden = !info.showHeadImage
            break
        case .board:
            headImageView.isHidden = true
            break
        case .screen:
            if info.isMe {
                displayLabel.text = NSLocalizedString("ui_t3", comment: "")
                displayLabel.isHidden = false
            }
            else {
                displayLabel.isHidden = true
            }
            videoView.isHidden = false
            headImageView.isHidden = true
            break
        }
        
        headImageViewWidthConstraint.constant =  72/2
        headImageViewHeightConstraint.constant =  72/2
        videoMaskImageView.isHidden = true
        videoMaskImageViewMini.isHidden = false
        
        contentView.layoutIfNeeded()
        headImageView.layer.cornerRadius = headImageViewWidthConstraint.constant/2
        headImageView.layer.masksToBounds = true
    }
    
    var getInfo: Info? {
        return info
    }

}

extension VideoCellMini {
    
    
    struct Info: Equatable {
        let isHost: Bool
        let enableAudio: Bool
        let name: String
        let headImageName: String
        let showHeadImage: Bool
        let hasDisplayInMainScreen: Bool
        let type: InfoType
        let isMe: Bool
        let streamId: String
        let userId: String
        let board: boardInfo?
        
        enum InfoType: Int {
            case video = 0
            case screen = 1
            case board = 2
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.isHost == rhs.isHost &&
                lhs.enableAudio == rhs.enableAudio &&
                lhs.name == rhs.name &&
                lhs.headImageName == rhs.headImageName &&
                lhs.showHeadImage == rhs.showHeadImage &&
                lhs.hasDisplayInMainScreen == rhs.hasDisplayInMainScreen &&
                lhs.type == rhs.type &&
                lhs.isMe == rhs.isMe &&
                lhs.streamId == rhs.streamId &&
                lhs.userId == rhs.userId &&
                lhs.board == rhs.board
        }
        
        struct boardInfo: Equatable {
            let id: String
            let token: String
            
            static var empty: boardInfo {
                return boardInfo(id: "", token: "")
            }
            
            static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.id == rhs.id &&
                    lhs.token == rhs.token
            }
        }
    }
}

