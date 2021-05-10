//
//  AboutVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/25.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import AgoraRtcKit
import Whiteboard
import AgoraRtmKit

class AboutVC: BaseViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var docButton: UIButton!
    @IBOutlet weak var bottomButton1: UIButton!
    @IBOutlet weak var bottomButton2: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        commonInit()
    }
    
    func setup() {
        title = NSLocalizedString("ab_t2", comment: "")
        docButton.layer.masksToBounds = true
        docButton.layer.cornerRadius = 2
        docButton.layer.borderColor = UIColor(hex: 0x4DA1FF).cgColor
        docButton.layer.borderWidth = 1
        
        let att1: [NSAttributedString.Key: Any] = [
              .font: UIFont.systemFont(ofSize: 12),
              .foregroundColor: UIColor(hex: 0x2E3848),
              .underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributeString1 = NSMutableAttributedString(string: NSLocalizedString("ab_t1", comment: ""),
                                                            attributes: att1)
        bottomButton1.setAttributedTitle(attributeString1, for: .normal)
        
        let att2: [NSAttributedString.Key: Any] = [
              .font: UIFont.systemFont(ofSize: 12),
              .foregroundColor: UIColor(hex: 0x2E3848),
              .underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributeString2 = NSMutableAttributedString(string: NSLocalizedString("ab_t3", comment: ""),
                                                         attributes: att2)
        bottomButton2.setAttributedTitle(attributeString2, for: .normal)
        
        versionLabel.text = versionString
        
    }
    
    
    func commonInit() {
        bottomButton1.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        bottomButton2.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        docButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
    }

    @objc func buttonTap(button: UIButton) {
        if button == bottomButton1 {
            let vc = BrowserVC(contentType: .disclaimer)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if button == bottomButton2 {
            let vc = BrowserVC(contentType: .privacyPolicy)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if button == docButton {
            guard let url = URL(string: "https://docs.agora.io") else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            return
        }
        
        if button == registerButton {
            let string = NSLocalizedString("ab_t1", comment: "") == "免责声明" ? "https://sso.agora.io/cn/v3/signup" : "https://sso.agora.io/en/v3/signup"
            guard let url = URL(string: string) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            return
        }
    }
    
    
    var versionString: String {
        let infoDict = Bundle.main.infoDictionary!
        let version = (infoDict["CFBundleShortVersionString"] as! String)
        let buildVersion = (infoDict["CFBundleVersion"] as! String)
        let appVersionStr = version + "(\(buildVersion))"
        let appTime = (infoDict["AppBuildTime"] as? String) ?? ""
        let versionInd = NSLocalizedString("ab_t5", comment: "")
        let timeInd = NSLocalizedString("ab_t6", comment: "")
        let videoSDKInd = NSLocalizedString("ab_t7", comment: "")
        let rtmSDKInd = NSLocalizedString("ab_t8", comment: "")
        let whiteboardSDKInd = NSLocalizedString("ab_t9", comment: "")
        
        let appVersion = versionInd + "\(appVersionStr)\(timeInd)\(appTime)"
        
        let rtcVersionStr = AgoraRtcEngineKit.getSdkVersion()
        let rtcVersion = "\(videoSDKInd)\(rtcVersionStr)"
        
        let rtmVersionStr = AgoraRtmKit.getSDKVersion() ?? ""
        let rtmVersion = "\(rtmSDKInd)\(rtmVersionStr)"
         
        let boardVersionStr = WhiteSDK.version()
        let boardVersion = "\(whiteboardSDKInd)\(boardVersionStr)"
        
        return appVersion + "\n" + rtcVersion + rtmVersion + "\n" + boardVersion
    }
}
