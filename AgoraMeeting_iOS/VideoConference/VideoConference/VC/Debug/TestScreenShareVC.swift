//
//  TestScreenShareVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/4/26.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import ReplayKit

@available(iOS 12.0, *)
class TestScreenShareVC: UIViewController {

    var rpPickerView: RPSystemBroadcastPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        rpPickerView = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: view.frame.size.height - 60, width: 60, height: 60))
        rpPickerView?.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        rpPickerView?.showsMicrophoneButton = true

        if let url = Bundle.main.url(forResource: "ScreenSharingBroadcast", withExtension: "appex", subdirectory: "PlugIns") {
            if let bundle = Bundle(url: url) {
                rpPickerView?.preferredExtension = bundle.bundleIdentifier
            }
        }
        view.addSubview(rpPickerView!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTapArPickerButton()
    }

    func handleTapArPickerButton() {
        if let subs = rpPickerView?.subviews {
            for view in subs {
                if let btn = view as? UIButton {
                    btn.sendActions(for: .allTouchEvents)
                }
            }
        }
    }

}
