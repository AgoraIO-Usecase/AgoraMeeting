//
//  LoginVM.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/14.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRoom
import AgoraRte
import AgoraSceneStatistic

protocol LoginVMDelegate: NSObject {
    func loginVMDidFailEntryRoomWithTips(tips: String)
    func loginVMDidSuccessEntryRoomWithInfo(info: LoginVM.Info)
    func loginVMShouldUpdateNetworkImage(imageName: String)
    func loginVMShouldShowUpdateVersion()
    func loginVMShouldChangeJoinButtonEnable(enable: Bool)
}

class LoginVM: NSObject {
    weak var delegate: LoginVMDelegate?
    let networkTest = NetworkTest(appId: KeyCenter.agoraAppid())
    let currentUserId = ARUserDefaults.getCurrentUUID()
    
    override init() {
        super.init()
        commonInit()
    }
    
    func commonInit() {
        networkTest.delegate = self
        startNetworkTest()
    }
    
    func startNetworkTest() {
        networkTest.start()
    }
    
    func stopNetworkTest() {
        networkTest.stop()
    }
    
    static func checkInputValid(userName: String, roomPsd: String, roomName: String) -> String? {
        
        if roomName.count == 0 {
            return NSLocalizedString("login_t0", comment: "")
        }
        if userName.count == 0 {
            return NSLocalizedString("login_t1", comment: "")
        }
        
        if roomName.count < 3 {
            return NSLocalizedString("login_t2", comment: "")
        }
        if roomName.count < 3 {
            return NSLocalizedString("login_t2", comment: "")
        }
        if roomName.count > 50 {
            return NSLocalizedString("login_t4", comment: "")
        }
        if userName.count <= 0 {
            return NSLocalizedString("login_t1", comment: "")
        }
        if userName.count < 3 {
            return NSLocalizedString("login_t3", comment: "")
        }
        if userName.count > 20 {
            return NSLocalizedString("login_t5", comment: "")
        }
        if roomPsd.count > 20 {
            return NSLocalizedString("login_t6", comment: "")
        }
        return nil
    }
    
    static func saveEntryParams(params: ARConferenceEntryParams) {
        ARUserDefaults.setUserName(params.userName)
        ARUserDefaults.setOpenCamera(params.videoAccess)
        ARUserDefaults.setOpenMic(params.audioAccess)
    }
    
    func entryRoom(info: Info) {
        let params = ARConferenceEntryParams()
        params.userName = info.userName
        params.roomName = info.roomName
        params.audioAccess = info.enableAudio
        params.videoAccess = info.enableVideo
        params.userUuid = info.userId
        params.roomUuid = info.roomId
        params.password = info.password
        params.appId = KeyCenter.agoraAppid()
        params.customerId = KeyCenter.customerId()
        params.customerCertificate = KeyCenter.customerCertificate()
        params.avatar = "";
        params.logFilePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                 .userDomainMask,
                                                                 true).first!.appending("/Logs")
        params.logPrintType = .error
        stopNetworkTest()
        delegate?.loginVMShouldChangeJoinButtonEnable(enable: false)
        ARConferenceManager.entryRoom(with: params) { [weak self] in
            self?.delegate?.loginVMShouldChangeJoinButtonEnable(enable: true)
            LoginVM.saveEntryParams(params: params)
            self?.delegate?.loginVMDidSuccessEntryRoomWithInfo(info: info)
            self?.logWhenLoginSuccess()
            self?.saveData(info: info)
        } fail: { [weak self](error) in
            self?.delegate?.loginVMShouldChangeJoinButtonEnable(enable: true)
            let tips = error?.localizedDescription ?? NSLocalizedString("进入失败", comment: "")
            self?.delegate?.loginVMDidFailEntryRoomWithTips(tips: tips)
            Log.error(error: error)
            self?.startNetworkTest()
        }
    }
    
    func signalImageName(type: AgoraRteNetworkQuality) -> String? {
        switch type {
        case .excellent:
            return "signal_good"
        case .good:
            return "signal_bad"
        case .poor:
            return "signal_poor"
        default:
            return "signal_unknown"
        }
    }
    
    func cleanData() {
        ARConferenceManager.cleanData()
    }
    
    func checkUpdate() {
        if let infoDict = Bundle.main.infoDictionary,
           let appVersion = (infoDict["CFBundleShortVersionString"] as? String) {
            HttpManager.requestAppVersion(withAppVersion: appVersion) { (resp) in
                if resp.forcedUpgrade != 0 {
                    self.delegate?.loginVMShouldShowUpdateVersion()
                }
            } failure: { (error) in
                
            }
        }
    }
    
    func saveData(info: Info) {
        ARUserDefaults.setUserName(info.userName)
        ARUserDefaults.setRoomName(info.roomName)
    }
    
}

extension LoginVM: NetworkTestDelegate {
    
    func networkTestDidUpdateQuality(networkTest: NetworkTest, quality: AgoraRteNetworkQuality) {
        guard let imageName = signalImageName(type: quality) else {
            return
        }
        delegate?.loginVMShouldUpdateNetworkImage(imageName: imageName)
    }
    
}

extension LoginVM {
    struct Info {
        let userName: String
        let roomName: String
        let password: String
        let enableVideo: Bool
        let enableAudio: Bool
        let userId: String
        let roomId: String
    }
}
