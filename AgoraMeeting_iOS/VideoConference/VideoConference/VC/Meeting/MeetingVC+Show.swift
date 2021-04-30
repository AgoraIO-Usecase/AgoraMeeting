//
//  MeetingVC+Show.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/15.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

extension MeetingVC {
    func showMoreAlert(info: MeetingVM.MoreAlertShowInfo) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: NSLocalizedString("meeting_t44", comment: ""), style: .default, handler: { (_) in
            self.copyShareInfo()
        })
        let action2 = UIAlertAction(title: NSLocalizedString("meeting_t6", comment: ""), style: .default, handler: { _ in
            self.showCLoseAllMicAlert()
        })
        let action3 = UIAlertAction(title: NSLocalizedString("meeting_t5", comment: ""), style: .default, handler: { _ in
            self.showCloseAllCameraAlert()
        })
        let action4 = UIAlertAction(title: NSLocalizedString("meeting_t17", comment: ""), style: .default, handler: { (_) in
            self.showScreenStarAlert()
        })
        let action5 = UIAlertAction(title: NSLocalizedString("meeting_t62", comment: ""), style: .default, handler: { (_) in
            self.showEndScreenAlert()
        })
        let action6 = UIAlertAction(title: NSLocalizedString("meeting_t10", comment: ""), style: .default, handler: { (_) in
            self.vm.requestWhiteBoardStart()
        })
        let action7 = UIAlertAction(title: NSLocalizedString("meeting_t41", comment: ""), style: .default) { (_) in
            self.showSetVC()
        }
        let action8 = UIAlertAction(title: NSLocalizedString("meeting_t11", comment: ""), style: .cancel, handler: nil)
        
        vc.addAction(action1)
        info.canCloseAllAudio ? vc.addAction(action2) : nil
        info.canCloseAllVideo ? vc.addAction(action3) : nil
        info.canStartScreen ? vc.addAction(action4) : nil
        info.canEndScreen ? vc.addAction(action5) : nil
        vc.addAction(action6)
        vc.addAction(action7)
        vc.addAction(action8)
        present(vc, animated: true, completion: nil)
    }
    
    func showSetVC() {
        let vc = SetVC(info: vm.setVCInfo)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func copyShareInfo() {
        let roomName = vm.loginInfo.roomName
        let invitedName = vm.loginInfo.userName
        let psd = vm.loginInfo.password
        let info = ShareSheetVC.Info(roomName: roomName, invitedName: invitedName, psd: psd)
        let pasteboard = UIPasteboard.general
        let webLink = "https://solutions.agora.io/meeting/web"
        let androidLink = "https://agora-adc-artifacts.oss-cn-beijing.aliyuncs.com/apk/app-AgoraMeeting.apk"
        let iOSLink = "https://www.pgyer.com/EUWO"
        var str = ""
        let roomNameInd = NSLocalizedString("invite_t1", comment: "")
        let roomPsdInd = NSLocalizedString("invite_t2", comment: "")
        let invitedInd = NSLocalizedString("invite_t3", comment: "")
        let webInd = NSLocalizedString("invite_t4", comment: "")
        let androidInd = NSLocalizedString("invite_t5", comment: "")
        let iOSInd = NSLocalizedString("invite_t6", comment: "")
        str += roomNameInd + info.roomName
        str += "\n"
        str += roomPsdInd + info.psd
        str += "\n"
        str += invitedInd + info.invitedName
        str += "\n"
        str += webInd + webLink
        str += "\n"
        str += androidInd + androidLink
        str += "\n"
        str += iOSInd + iOSLink
        pasteboard.string = str
        showToast(NSLocalizedString("meeting_t51", comment: ""))
    }
    
    func showMemberVC() {
        let infos = vm.infos.map({ MemberVM.Info(userId: $0.user.userId, uiInfo: $0.toUserCellInfo) })
        let vc = MemberVC(infos: infos)
        memberVC = vc
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChatVC() {
        let vc = MessageVC()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// auto touch up inside the rpPickerView
    func handleTapArPickerButton() {
        if #available(iOS 12.0, *) {
            for view in rpPickerView.subviews {
                if let btn = view as? UIButton {
                    Log.info(text: "did auto handleTapArPickerButton")
                    if let systemVersion = Double(UIDevice.current.systemVersion.split(separator: ".").first ?? "0"),
                       systemVersion >= 12.0,
                       systemVersion < 13.0 {
                        btn.sendActions(for: .allTouchEvents)
                    }
                    else {
                        btn.sendActions(for: .touchUpInside)
                    }
                }
            }
        }
    }
    
    func showLeaveRoomSheet() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let a1 = UIAlertAction(title: NSLocalizedString("meeting_t40", comment: ""), style: .default) { (_) in
            self.vm.endRoom()
        }
        let a2 = UIAlertAction(title: NSLocalizedString("meeting_t43", comment: ""), style: .default) { (_) in
            self.vm.leave()
        }
        let a3 = UIAlertAction(title: NSLocalizedString("meeting_t11", comment: ""), style: .cancel, handler: nil)
        if vm.localUser.info.isHost { vc.addAction(a1) }
        vc.addAction(a2)
        vc.addAction(a3)
        present(vc, animated: true, completion: nil)
    }
    
    
    func showRequestMicAlert() {
        let vc = UIAlertController(title: nil, message: NSLocalizedString("meeting_t16", comment: ""), preferredStyle: .alert)
        let a1 = UIAlertAction(title: NSLocalizedString("meeting_t33", comment: ""), style: .default, handler: { [unowned self](_) in
            self.vm.requestAudioOpen(audioOpenShouldApply: true)
        })
        let a2 = UIAlertAction(title: NSLocalizedString("meeting_t11", comment: ""), style: .default, handler: nil)
        vc.addAction(a2)
        vc.addAction(a1)
        present(vc, animated: true, completion: nil)
    }
    
    func showRequestCameraAlert() {
        let vc = UIAlertController(title: nil, message: NSLocalizedString("meeting_t15", comment: ""), preferredStyle: .alert)
        let a1 = UIAlertAction(title: NSLocalizedString("meeting_t33", comment: ""), style: .default, handler: {  [unowned self](_) in
            self.vm.requestVideoOpen(videoOpenShouldApply: true)
        })
        let a2 = UIAlertAction(title: NSLocalizedString("meeting_t11", comment: ""), style: .default, handler: nil)
        vc.addAction(a2)
        vc.addAction(a1)
        present(vc, animated: true, completion: nil)
    }
    
    func showKickoutAlert() {
        let vc = UIAlertController(title: nil, message: NSLocalizedString("meeting_t24", comment: ""), preferredStyle: .alert)
        let a1 = UIAlertAction(title: NSLocalizedString("是", comment: ""), style: .default, handler: { _ in
            self.dismiss(animated: true) {
                self.meetingVMDidLeaveRoom()
            }
        })
        vc.addAction(a1)
        present(vc, animated: true, completion: nil)
    }
    
    func showRoomEndAlert() {
        let vc = UIAlertController(title: nil, message: NSLocalizedString("meeting_t3", comment: ""), preferredStyle: .alert)
        let a1 = UIAlertAction(title: NSLocalizedString("meeting_t61", comment: ""), style: .default, handler: { _ in
            self.meetingVMWillLeaveRoom()
        })
        vc.addAction(a1)
        present(vc, animated: true, completion: nil)
    }
    
    static func showSystemSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func showScoreView() {
        let vc = ASScoreAlertVC()
        vc.submitBlock = { score in
            self.vm.submitScore(score: score)
        }
        vc.dismissBlock = { [unowned self] in
            self.vm.handleScoreDismiss()
        }
        vc.show(in: self)
    }
    
    func showCloseAllCameraAlert() {
        let vc = ASCheckBoxAlertVC()
        vc.delegate = self
        vc.show(in: self, style: .video)
    }
    
    func showCLoseAllMicAlert() {
        let vc = ASCheckBoxAlertVC()
        vc.delegate = self
        vc.show(in: self, style: .audio)
    }
    
    func showScreenStarAlert() {
        let title = NSLocalizedString("meeting_t53", comment: "")
        let vc = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action1Title = NSLocalizedString("meeting_t52", comment: "")
        let action1 = UIAlertAction(title: action1Title, style: .default) { (_) in
            self.vm.startScreenShare()
        }
        let action2Title = NSLocalizedString("meeting_t11", comment: "")
        let action2 = UIAlertAction(title: action2Title, style: .default, handler: nil)
        vc.addAction(action2)
        vc.addAction(action1)
        present(vc, animated: true, completion: nil)
    }
    
    func showEndBoardAlert() {
        let title = NSLocalizedString("meeting_t54", comment: "")
        let vc = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action1Title = NSLocalizedString("meeting_t39", comment: "")
        let action1 = UIAlertAction(title: action1Title, style: .default) { [unowned self](_) in
            self.vm.closeWhiteBoard()
        }
        let action2Title = NSLocalizedString("meeting_t11", comment: "")
        let action2 = UIAlertAction(title: action2Title, style: .default, handler: nil)
        vc.addAction(action2)
        vc.addAction(action1)
        present(vc, animated: true, completion: nil)
    }
    
    func showEndScreenAlert() {
        let title = NSLocalizedString("meeting_t55", comment: "")
        let vc = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action1Title = NSLocalizedString("meeting_t39", comment: "")
        let action1 = UIAlertAction(title: action1Title, style: .default) { (_) in
            self.vm.stopScreenShare()
        }
        let action2Title = NSLocalizedString("meeting_t11", comment: "")
        let action2 = UIAlertAction(title: action2Title, style: .default, handler: nil)
        vc.addAction(action2)
        vc.addAction(action1)
        present(vc, animated: true, completion: nil)
    }
    
    func showSelectedNotiTypeVC() {
        showSetVC()
    }
    
    func shouldPopWhiteBoardVC() {
        if let lastVc = navigationController?.viewControllers.last,
           lastVc.isKind(of: WhiteBoardVC.self) {
            navigationController?.popToViewController(self, animated: true)
        }
    }
    
}

