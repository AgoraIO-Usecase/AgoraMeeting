//
//  ShareView.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/16.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

class ShareView: UIView {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var invitedLabel: UILabel!
    @IBOutlet weak var psdLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var cancleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner];
        
        copyButton.layer.cornerRadius = 2.5
        copyButton.layer.masksToBounds = true
        
    }
    
    
    
}
