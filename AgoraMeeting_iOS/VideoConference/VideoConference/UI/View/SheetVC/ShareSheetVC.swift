//
//  ShareSheetVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/16.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import Presentr

protocol ShareSheetVCDelegate: NSObject {
    func shareSheetVCdidCopyInfo()
}

class ShareSheetVC: UIViewController {
    private let shareView = Bundle.main.loadNibNamed("ShareView", owner: nil, options: nil)?.first as! ShareView
    private let presenter = Presentr(presentationType: .bottomHalf)
    private var info: Info!
    weak var delegate: ShareSheetVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        view.addSubview(shareView)
        shareView.translatesAutoresizingMaskIntoConstraints = false
        
        shareView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        shareView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        shareView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        shareView.heightAnchor.constraint(equalToConstant: 355).isActive = true
        
        shareView.cancleButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        shareView.copyButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
    }
    
    public func show(in vc: UIViewController, info: Info) {
        self.info = info
        shareView.roomNameLabel.text = "会议名：" + info.roomName
        shareView.invitedLabel.text = "邀请人：" + info.invitedName
        shareView.psdLabel.text = "会议密码：" + info.psd
        vc.customPresentViewController(presenter, viewController: self, animated: true, completion: nil)
    }
    
    @objc func buttonTap(button: UIButton) {
        if button == shareView.cancleButton {
            dismiss(animated: true, completion: nil)
        }
        else {
            copyInfo()
            dismiss(animated: true, completion: {
                self.delegate?.shareSheetVCdidCopyInfo()
            })
            
        }
    }
    
    func copyInfo() {
        let pasteboard = UIPasteboard.general
        let webLink = "web下载链接：https://solutions.agora.io/meeting/web"
        let androidLink = "Android下载链接：https://agora-adc-artifacts.oss-cn-beijing.aliyuncs.com/apk/app-AgoraMeeting.apk"
        let iOSLink = info.link
        var str = ""
        str += info.roomName
        str += "\n"
        str += info.psd
        str += "\n"
        str += info.invitedName
        str += "\n"
        str += webLink
        str += "\n"
        str += androidLink
        str += "\n"
        str += iOSLink
        pasteboard.string = str
    }
    
}

extension ShareSheetVC {
    struct Info {
        let roomName: String
        let invitedName: String
        let psd: String
        let link = "https://videocall.agora.io/#/391830718"
    }
}
