//
//  UserCell.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/18.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hostImageVIew: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var audioImageView: UIImageView!
    var info: Info?
    static let idf = "UserCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        headImageView.layer.cornerRadius = 15
        headImageView.layer.masksToBounds = true
    }
    
    func setInfo(info: Info) {
        self.info = info
        headImageView.image = UIImage(named: info.headImageName)
        nameLabel.attributedText = info.attributedTitle
        
        videoImageView.image = info.videoEnable ? UIImage(named: "member-video1") : UIImage(named: "member-video0")
        audioImageView.image = info.audioEnable ? UIImage(named: "member-audio4") : UIImage(named: "member-audio0")
        
        let hostImageName = "member-host"
        let shareImageName = "member-share"
        if info.isHost, !info.isShare {
            shareImageView.image = UIImage(named: hostImageName)
            shareImageView.isHidden = false
            hostImageVIew.isHidden = true
        }
        if !info.isHost, info.isShare {
            shareImageView.image = UIImage(named: shareImageName)
            shareImageView.isHidden = false
            hostImageVIew.isHidden = false
        }
        if info.isHost, info.isShare {
            shareImageView.image = UIImage(named: shareImageName)
            shareImageView.isHidden = false
            hostImageVIew.image = UIImage(named: hostImageName)
            hostImageVIew.isHidden = false
        }
        if !info.isHost, !info.isShare {
            hostImageVIew.isHidden = true
            shareImageView.isHidden = true
        }
    }

}

extension UserCell {
    struct Info {
        let headImageName: String
        let title: String
        let name: String
        let userId: String
        let isHost: Bool
        var isShare: Bool
        let videoEnable: Bool
        let audioEnable: Bool
        var attributedTitle: NSMutableAttributedString?
        
        mutating func setAttributeTitle(attributedTitle: NSMutableAttributedString) {
            self.attributedTitle = attributedTitle
        }
        
        mutating func setShare(share: Bool) {
            isShare = share
        }
    }
}
