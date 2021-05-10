//
//  LoginVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/4.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import ReplayKit
import AVKit

class LoginVC: BaseViewController {
    @IBOutlet weak var textFieldBgView: UIView!
    @IBOutlet weak var cameraSwitch: UISwitch!
    @IBOutlet weak var micSwitch: UISwitch!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var roomNameTextField: UITextField!
    @IBOutlet weak var roomPsdTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var signalImageView: UIImageView!
    @IBOutlet weak var debugButton: UIButton!
    @IBOutlet weak var roomNameMaskView: UIView!
    @IBOutlet weak var roomPsdMaskView: UIView!
    @IBOutlet weak var userNameMaskView: UIView!
    @IBOutlet weak var tipsButton: UIButton!
    private let tipView2 = LoginTipsView()
    let vm = LoginVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        cameraSwitch.isOn = ARUserDefaults.getOpenCamera()
        micSwitch.isOn = ARUserDefaults.getOpenMic()
        userNameTextField.text = ARUserDefaults.getUserName()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        ARUserDefaults.setUserName(userNameTextField.text!)
    }
    
    func setup() {
        tipView2.isHidden = true
        view.addSubview(tipView2)
        tipView2.translatesAutoresizingMaskIntoConstraints = false
        let height: CGFloat = NSLocalizedString("login_t0", comment: "") == "请输入房间名" ? 103 : 130
        
        NSLayoutConstraint.activate([tipView2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -33),
                                     tipView2.topAnchor.constraint(equalTo: tipsButton.centerYAnchor, constant: 8),
                                     tipView2.widthAnchor.constraint(equalToConstant: 261),
                                     tipView2.heightAnchor.constraint(equalToConstant: height)])
        
        userNameTextField.text = ARUserDefaults.getUserName()
        
        view.backgroundColor = .white
        vm.delegate = self
        textFieldBgView.layer.borderWidth = 1
        textFieldBgView.layer.borderColor = UIColor(hex: 0xE9EFF4).cgColor
        textFieldBgView.layer.cornerRadius = 2
        
        vm.checkUpdate()
        
        #if DEBUG
        roomNameTextField.text = ARUserDefaults.getRoomName()
        debugButton.isHidden = false
        #endif
        
        roomNameTextField.delegate = self
        roomPsdTextField.delegate = self
        userNameTextField.delegate = self
        
        roomNameMaskView.isHidden = true
        roomNameMaskView.layer.borderWidth = 1
        roomNameMaskView.layer.borderColor = UIColor(hex: 0x4DA1FF).cgColor
        roomNameMaskView.layer.cornerRadius = 2
        roomNameMaskView.isUserInteractionEnabled = false
        
        roomPsdMaskView.isHidden = true
        roomPsdMaskView.layer.borderWidth = 1
        roomPsdMaskView.layer.borderColor = UIColor(hex: 0x4DA1FF).cgColor
        roomPsdMaskView.layer.cornerRadius = 2
        roomPsdMaskView.isUserInteractionEnabled = false
        
        userNameMaskView.isHidden = true
        userNameMaskView.layer.borderWidth = 1
        userNameMaskView.layer.borderColor = UIColor(hex: 0x4DA1FF).cgColor
        userNameMaskView.layer.cornerRadius = 2
        userNameMaskView.isUserInteractionEnabled = false
    }

    @IBAction func onClickSet(_ sender: Any) {
        view.endEditing(true)
        showLoginSetVC()
    }
    
    @IBAction func onSwitchCamera(_ sender: Any) {
        ARUserDefaults.setOpenCamera(cameraSwitch.isOn)
        tipView2.isHidden = true
    }
    
    @IBAction func onSwitchMic(_ sender: Any) {
        ARUserDefaults.setOpenMic(micSwitch.isOn)
        tipView2.isHidden = true
    }
    
    @IBAction func onClickJoin(_ sender: UIButton) {
        view.endEditing(true)

        let userName = userNameTextField.text!
        let roomPsd = roomPsdTextField.text!
        let roomName = roomNameTextField.text!
        if let tipString = LoginVM.checkInputValid(userName: userName, roomPsd: roomPsd, roomName: roomName) {
            showToast(tipString)
            return
        }

        showLoading()
        let enableVideo = cameraSwitch.isOn
        let enableAudio = micSwitch.isOn
        let info = LoginVM.Info(userName: userName,
                                roomName: roomName,
                                password: roomPsd,
                                enableVideo: enableVideo,
                                enableAudio: enableAudio,
                                userId: vm.currentUserId,
                                roomId: roomName.md5())
        vm.entryRoom(info: info)
    }
    
    @IBAction func onClickTip(_ sender: Any) {
        tipView2.isHidden = !tipView2.isHidden
    }
    
    func showTipsTimeLimit() {

    }
    
    func showMeetingVC(info: LoginVM.Info) {
        let vc = MeetingVC(loginInfo: info)
        vc.delegate = self
        let nvc = NavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .fullScreen
        present(nvc, animated: true, completion: nil)
    }
    
    func showLoginSetVC() {
        let userName = userNameTextField.text!
        let headImageName = String.headImageName(userName: userNameTextField.text!.md5())
        let videoAccess = cameraSwitch.isOn
        let audioAccess = cameraSwitch.isOn
        let info = LoginSetVC.Info(headImageName: headImageName,
                                   userName: userName,
                                   audioAccess: audioAccess,
                                   videoAccess: videoAccess)
        let vc = LoginSetVC(info: info, uploadLogUserId: vm.currentUserId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tipView2.isHidden = true
        view.endEditing(true)
    }
    
    func showUpdateAlertVC() {
        let vc = UIAlertController(title:  NSLocalizedString("login_t9", comment: ""), message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("login_t7", comment: ""), style: .default) { (_) in
            /// en: https://docs.agora.io/en/All/downloads?platform=All%20Platforms
            if let url = URL(string: "https://docs.agora.io/cn/All/downloads?platform=All%20Platforms") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        vc.addAction(action)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func debugTap(_ sender: Any) {
        #if DEBUG
//        let vc = TestNotiCellVC()
        let vc = DebugVC()
        navigationController?.pushViewController(vc, animated: true)
        #endif
    }
    
}

extension LoginVC: LoginVMDelegate, MeetingVCDelegate {
    
    func loginVMShouldChangeJoinButtonEnable(enable: Bool) {
        joinButton.isEnabled = enable
    }
    
    func loginVMShouldShowUpdateVersion() {
        showUpdateAlertVC()
    }
    
    func meetingVCDidExitRoom() {
        vm.startNetworkTest()
        vm.cleanData()
    }
    
    func loginVMShouldUpdateNetworkImage(imageName: String) {
        signalImageView.image = UIImage(named: imageName)
    }
    
    func loginVMDidFailEntryRoomWithTips(tips: String) {
        dismissLoading()
        showToast(tips)
    }
    
    func loginVMDidSuccessEntryRoomWithInfo(info: LoginVM.Info) {
        dismissLoading()
        showMeetingVC(info: info)
        showTipsTimeLimit()
    }
}

extension LoginVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let count = textField.text?.count {
            if textField == roomNameTextField, count == 50 {
                if string == "" { return true }
                let tips = NSLocalizedString("login_t4", comment: "")
                showToastCenter(tips)
                return false
            }
            if textField == userNameTextField, count == 20 {
                if string == "" { return true }
                let tips = NSLocalizedString("login_t5", comment: "")
                showToastCenter(tips)
                return false
            }
            if textField == roomPsdTextField, count == 20 {
                if string == "" { return true }
                let tips = NSLocalizedString("login_t6", comment: "")
                showToastCenter(tips)
                return false
            }
        }
        
        let len = string.lengthOfBytes(using: .utf8)
        if len >= 4 {
            return !string.containsEmoji
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if roomNameTextField == textField {
            roomNameMaskView.isHidden = false
        }
        if roomPsdTextField == textField {
            roomPsdMaskView.isHidden = false
        }
        if userNameTextField == textField {
            userNameMaskView.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if roomNameTextField == textField {
            roomNameMaskView.isHidden = true
        }
        if roomPsdTextField == textField {
            roomPsdMaskView.isHidden = true
        }
        if userNameTextField == textField {
            userNameMaskView.isHidden = true
        }
    }
    
    
}
