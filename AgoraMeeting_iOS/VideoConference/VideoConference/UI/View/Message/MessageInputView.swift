//
//  MessageView.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/23.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

class MessageInputView: UIView {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFiledBgView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textFiledBgView.layer.borderWidth = 1
        textFiledBgView.layer.borderColor = UIColor(hex: 0xcccccc).cgColor
        textFiledBgView.layer.cornerRadius = 2;
        sendButton.setImage(UIImage(named: "发送"), for: .normal)
        sendButton.setImage(UIImage(named: "发送"), for: .disabled)
        
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        sendButton.isEnabled = false
    }
    
}
