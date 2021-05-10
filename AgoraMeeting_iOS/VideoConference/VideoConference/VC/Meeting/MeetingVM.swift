//
//  MeetingVM2.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/8.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRoom
import AgoraRte
import WhiteModule
import AgoraSceneStatistic

class MeetingVM: NSObject {
    weak var delegate: MeetingVMProtocol?
    let localUser = ARConferenceManager.getLocalUser()
    let engine = ARConferenceManager.getRteEngine()
    let addRoomResp = ARConferenceManager.getAddRoomResp()
    var infos = [Info]()
    var loginInfo: LoginVM.Info!
    private var mode = MeetingViewMode.videoFlow
    var lastModeIsAudioTimeStamp: TimeInterval?
    var selectedInfo: Info?
    var screenInfo = ScreenInfo()
    let whiteBoardManager = WhiteManager()
    let videoApplyTimer = TimerSource()
    let audioApplyTimer = TimerSource()
    let autoAudioModeChecker = AutoAudioModeChecker()
    let autoHidenTimerSource = TimerSource()
    var lastNotiTime: TimeInterval? = 0
    let notiQueue = DispatchQueue(label: "notiQueue")
    let service = AgoraSceneStatistic()
    var lastRenderBoardId: String?
    let opQueue = DispatchQueue(label: "MeetingVM.opQueue")
    var sceneProperties: [String : Any]?
    var endRoomFromMe = false
    var hasRecvRtmFailState = false
    var lastUpdate: UpdateInfo?
    var shouldAutoUp = true
    let appGroupsString = "group.io.agora.meetingInternal"
    
    convenience init(loginInfo: LoginVM.Info) {
        self.init()
        self.loginInfo = loginInfo
        setup()
        commonInit()
        videoApplyTimer.tag = 2
        registerNotiFormScreenShareExtension()
    }
    
    func start() {
        let scene = ARConferenceManager.getScene()
        
        infos = fetchInfos()
        updateButtomViewIfNeed()
        fetchWhiteBoardInfo(scene:  scene)
        handleCheckScreenInfo(scene: scene)
        updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
        ARConferenceManager.getScene().sceneDelegate = self
        ARConferenceManager.getRteEngine().getAgoraMediaControl().delegate  = self
        ARConferenceManager.getRteEngine().delegate = self
        localUser.localUserDelegate = self
        sceneProperties = scene.properties
        checkNoti()
    }
    
    func leave() {
        let scene = ARConferenceManager.getScene()
        let params = ARConferenceManager.getEntryParams()
        let roomId = params.roomUuid
        let userId = params.userUuid
        HttpManager.requestLeaveRoom(withRoomId: roomId, userId: userId) {  [weak self] in
            scene.leave()
            self?.invokeMeetingVMWillLeaveRoom()
        } faulure: { [weak self](error) in
            self?.invokeMeetingVMLeaveRoomErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func endRoom() {
        let scene = ARConferenceManager.getScene()
        let params = ARConferenceManager.getEntryParams()
        let roomId = params.roomUuid
        let userId = params.userUuid
        endRoomFromMe = true
        HttpManager.requestEndRoom(withRoomId: roomId, userId: userId) {  [weak self] in
            scene.leave()
            self?.invokeMeetingVMWillLeaveRoom()
        } faulure: { [weak self](error) in
            self?.endRoomFromMe = false
            self?.invokeMeetingVMLeaveRoomErrorWithTips(tips: error.localizedDescription)
        }
    }
           
    deinit {
        engine.destroy()
        MessageCollector.default.clean()
        MessageCollector.default.cleanUnReadCount()
        NotiCollector.default.clean()
        autoAudioModeChecker.stopRecord()
        unregisterNotiFormScreenShareExtension()
    }
    
    func destoryTimer() {
        videoApplyTimer.invalied()
        audioApplyTimer.invalied()
        autoAudioModeChecker.invalied()
        autoHidenTimerSource.invalied()
    }
    
    func setup() {}
    
    func commonInit() {
        videoApplyTimer.delegate = self
        audioApplyTimer.delegate = self
        autoAudioModeChecker.delegate = self
        autoHidenTimerSource.delegate = self
        addNotiObserver()
    }
    
    /// 放弃主持人
    func abandonHost() {
        let reqParams = HMReqParamsHostAbondon()
        reqParams.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParams.userId = ARConferenceManager.getEntryParams().userUuid
        invokeMeetingVMShouldShowLoading()
        HttpManager.requestHostAbandon(withParam: reqParams) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.invokeMeetingVMShouldDismissLoading()
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    /// 设为主持人
    func setHost(isMe: Bool, targetUserId: String) {
        if isMe {
            setMeAsHost()
            return
        }
        
        let reqParam = HMReqParamsKickout()
        reqParam.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParam.userId = localUser.info.userId
        reqParam.targetUserId = targetUserId
        self.invokeMeetingVMShouldShowLoading()
        HttpManager.requestAppointHost(withParam: reqParam) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.invokeMeetingVMShouldDismissLoading()
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func setMeAsHost() {
        let reqParam = HMReqParamsHostAbondon()
        reqParam.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParam.userId = localUser.info.userId
        self.invokeMeetingVMShouldShowLoading()
        HttpManager.requestHostApply(withParam: reqParam) {  [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    /// 踢人 Kickout
    func removeUser(targetUserId: String) {
        let reqParams = HMReqParamsKickout()
        reqParams.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParams.targetUserId = targetUserId
        reqParams.userId = localUser.info.userId
        self.invokeMeetingVMShouldShowLoading()
        HttpManager.request(reqParams) {  [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    
    func closeRemoteVideoAudio(isVideo: Bool, targetUserId: String) {
        let reqParams = HMReqParamsUserPermissionsCloseSingle()
        reqParams.roomId = ARConferenceManager.getEntryParams().roomUuid
        reqParams.userId = localUser.info.userId
        reqParams.targetUserId = targetUserId
        if isVideo {
            reqParams.cameraClose = true
            reqParams.micClose = false
        }
        else {
            reqParams.cameraClose = false
            reqParams.micClose = true
        }
        self.invokeMeetingVMShouldShowLoading()
        HttpManager.reqCloseCameraMicSingle(reqParams) {  [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    /// for seconds
    func getRoomTime() -> Int {
        Int(Double(ARConferenceManager.getAddRoomResp().startTime))
    }
    
    func setMode(mode: MeetingViewMode) {
        self.mode = mode
    }
    
    func getMode() -> MeetingViewMode {
        return mode
    }
    
    
}

extension MeetingVM: AgoraRteLocalUserDelegate {
    
    func localUser(_ user: AgoraRteLocalUser, didUpdateLocalUserInfo userEvent: AgoraRteUserEvent) {
        updateLocalUserInfoOnQueue(event: userEvent)
        updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
        checkLocalUserInfoUpdateNoti(event: userEvent)
        checkNoti()
        Log.info(text: "didUpdateLocalUserInfo", tag: "MeetingVM")
    }
    
    func localUser(_ user: AgoraRteLocalUser, didUpdateLocalUserProperties changedProperties: [String], remove: Bool, cause: String?) {
        updateLocalUserPropertiesOnQueue(changedProperties: changedProperties)
    }
    
    func localUser(_ user: AgoraRteLocalUser, didChangeOfLocalStream event: AgoraRteMediaStreamEvent, with action: AgoraRteMediaStreamAction) {
        checkLocalStreamUpdateNoti(event: event)
        switch action {
        case .added:
            Log.info(text: "didChangeOfLocalStream added", tag: "MeetingVM")
            addLocalStreamOnQueue(event: event)
            updateLocalStreamOnQueue(event: event)
            updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
            break
        case .updated:
            Log.info(text: "didChangeOfLocalStream updated", tag: "MeetingVM")
            updateLocalStreamOnQueue(event: event)
            updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
            /// no in split video or audio
            invokeMeetingVMShouldChangeBottomViewState(isVideo: true, enable: true)
            invokeMeetingVMShouldChangeBottomViewState(isVideo: false, enable: true)
            break
        case .removed:/* invoke when audio and video were close **/
            removeLocalStreamOnQueue(event: event)
            updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
            Log.info(text: "didChangeOfLocalStream removed", tag: "MeetingVM")
            break
        default:
            break
        }
        
    }
    
}

extension MeetingVM: AgoraRteSceneDelegate {
    
    /** remote stream */
    
    func scene(_ scene: AgoraRteScene, didAddRemoteStreams streamEvents: [AgoraRteMediaStreamEvent]) {
        addRemoteStreamsOnQueue(events: streamEvents)
        updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
    }
    
    func scene(_ scene: AgoraRteScene, didRemoveRemoteStreams streamEvents: [AgoraRteMediaStreamEvent]) {
        removeRemoteStreamsOnQueue(events: streamEvents)
        updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
    }
    
    func scene(_ scene: AgoraRteScene, didUpdateRemoteStreams streamEvents: [AgoraRteMediaStreamEvent]) {
        updateRemoteStreamsOnQueue(events: streamEvents)
        updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
    }
    
    /** remote user */
    
    func scene(_ scene: AgoraRteScene, didRemoteUsersJoin userEvents: [AgoraRteUserEvent]) {
        addRemoteUserInfoOnQueue(events: userEvents, scene: scene)
        updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
        checkAttendsNumberNotiIfNeed()
    }
    
    func scene(_ scene: AgoraRteScene, didUpdateRemoteUserInfo userEvent: AgoraRteUserEvent) {
        updateRemoteUserInfoOnQueue(event: userEvent)
        updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
        checkRemoteUserInfoUpdateNoti(event: userEvent)
        checkNotiNoHost()
    }
    
    func scene(_ scene: AgoraRteScene, didUpdateRemoteUserProperties changedProperties: [String], remove: Bool, cause: String?, fromUser user: AgoraRteUserInfo) {
        updateRemoteUserPropertiesOnQueue(changedProperties: changedProperties, user: user)
        updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
    }
    
    func scene(_ scene: AgoraRteScene, didRemoteUsersLeave userEvents: [AgoraRteUserEvent]) {
        removeRemoteUsersInfoOnQueue(events: userEvents)
        updateInfoOnQueue(shouldAutoChangeToSpeakerMode: true)
        checkAttendsNumberNotiIfNeed()
    }
    
    /** scene */
    
    func scene(_ scene: AgoraRteScene, didReceiveSceneMessage message: AgoraRteMessage, fromUser user: AgoraRteUserInfo) {
        if let closeAllInfo = ChannelMesssageCloseAllCaremaMic.instance(jsonString: message.message) {
            checkAllClose(closeAllInfo: closeAllInfo)
            return;
        }
        guard user.userId != localUser.info.userId else {
            return
        }
        let info = MessageCollector.Info(userId: user.userId,
                                         userName: user.userName,
                                         message: message.message,
                                         timestamp: message.timestamp,
                                         isSelfSend: false,
                                         type: .chat,
                                         status: .recv)
        MessageCollector.default.add(message: info)
        MessageCollector.default.addUnReadCount()
    }
    
    func scene(_ scene: AgoraRteScene, didUpdateSceneProperties changedProperties: [String], remove: Bool, cause: String?) {
        Log.info(text: "didUpdateSceneProperties" + (scene.properties?.description ?? "") + "cause:\(cause ?? "nil")")
        handleWhiteBoardShareInfoChangeOnQueue(scene: scene, cause: cause)
        handleScreenInfoChangeOnQueue(scene: scene, cause: cause)
        handleRoomEndChange(scene: scene, cause: cause)
        checkNoti()
        checkScenePropertyUpdateNoti(scene: scene, cause: cause)
    }
    
    func scene(_ scene: AgoraRteScene, didChange state: AgoraRteSceneConnectionState, withError error: AgoraRteError?) {
        handleSceneConntectOnQueue(state: state, error: error)
    }
    
}

extension MeetingVM: AgoraRteMediaControlDelegate {
    func mediaControl(_ control: AgoraRteMediaControl, didChnageAudioRouting routing: AgoraRteAudioOutputRouting) {
        var type: RoutingType = .speaker
        switch routing {
        case .earpiece:
            type = .earpiece
            break
        case .headset, .headsetNoMic, .headsetBluetooth:
            type = .headSet
            break
        case .speakerphone, .loudspeaker:
            type = .speaker
            break
        default:
            return
        }
        invokeMeetingVMShouldAudioRouting(type: type)
    }
}

extension MeetingVM: AgoraRteEngineDelegate {
    /// Peer msg
    func rteEngine(_ engine: AgoraRteEngine, didReceivedMessage message: AgoraRteMessage, fromUserId userId: String) {
        Log.debug(text: message.description, tag: "didReceivedMessage")
        if let peerMsg = PeerMessage.instance(jsonString: message.message) {
            checkCameraMicOpenRequestNoti(message: peerMsg)
        }
    }
}

extension MeetingVM: MessageObserver {
    func update(newValue: [MessageCollector.Info]) {}
    
    func updateUnReadCount(count: Int) {
        invokeMeetingVmShouldUpdateImRedCount(count: count)
    }
}

