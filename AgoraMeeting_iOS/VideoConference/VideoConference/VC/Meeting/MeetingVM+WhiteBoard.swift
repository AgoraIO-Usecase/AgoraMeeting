//
//  MeetingVM+WhiteBoard.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/1.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRoom
import WhiteModule

extension MeetingVM {
    
    enum SceneShareType: Int {
        case none = 0
        case screen = 1
        case board = 2
    }
    
    func requestWhiteBoardStart() {
        let userId = localUser.info.userId
        let roomId = ARConferenceManager.getScene().info.sceneId
        let param = HMReqParamsHostAbondon()
        param.userId = userId
        param.roomId = roomId
        invokeMeetingVMShouldShowLoading()
        HttpManager.requestWhiteBoardStart(withParam: param) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.invokeMeetingVMShouldDismissLoading()
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func fetchWhiteBoardInfo(scene: AgoraRteScene) {
        guard let shareType = readShareFrom(scene: scene) else {
            return
        }
        switch shareType {
        case .board:
            guard let info = readBoardFrom(scene: scene) else {
                return
            }
            addWhiteBoardInfoIfNeed(info: info)
            break
        default:
            break
        }
    }
    
    func handleWhiteBoardShareInfoChange(scene: AgoraRteScene, cause: String?) {
        Log.info(text: "handleWhiteBoardShareInfoChange")
        guard let causeString = cause else {
            Log.errorText(text: "cause is nil")
            return
        }
        do {
            let cause = try Cause.decode(jsonString: causeString)
            let cmd = cause.getCmd
            switch cmd {
            case .startBoard:
                Log.info(text: " ---> startBoard")
                guard let info = readBoardFrom(scene: scene) else {
                    Log.errorText(text: "can not readBoardFrom ")
                    return
                }
                Log.info(text: "startBoard")
                addWhiteBoardInfoIfNeed(info: info)
                break
            case .closeBoard:
                Log.info(text: "---> closeBoard")
                removeWhiteBoardInfoIfNeed()
                invokeMeetingVMDidEndWhiteBoard()
                break
            case .boardInteracts:
                Log.info(text: "---> boardInteracts")
                break
            default:
                Log.info(text: "---> board default")
                break
            }
        } catch let e {
            Log.info(text: causeString)
            Log.error(error: e, tag: "checkRoomPropertyUpdateNoti")
        }
    }
    
    func readShareFrom(scene: AgoraRteScene) -> SceneShareType? {
        if let share = scene.properties?["share"] as? [String : Any] {
            if let type = share["type"] as? Int {
                return SceneShareType(rawValue: type)!
            }
            return nil
        }
        return nil
    }
    
    func readBoardFrom(scene: AgoraRteScene) -> MeetingVM.Info? {
        guard let boardInfo = scene.readBoardInfo() else {
            return nil
        }
        let userId = boardInfo.ownerInfo.userId
        let userName = boardInfo.ownerInfo.userName
        let userRole = boardInfo.ownerInfo.userRole
        let boardId = boardInfo.info.boardId
        let boardToken = boardInfo.info.boardToken
        let follow = boardInfo.state.follow
        let grantUsers = boardInfo.state.grantUsers
        let user = Info.User(userId: userId, userName: userName, userRole: userRole)
        let board = MeetingVM.Info.ShareBoardInfo(boardId: boardId,
                                                  boardToken: boardToken,
                                                  flow: follow == 1,
                                                  gentUsersIds: grantUsers)
        
        return MeetingVM.Info(type: .board, user: user, boardInfo: board)
    }
    
    func addWhiteBoardInfoIfNeed(info: MeetingVM.Info) {
        var temps = infos.filter({ $0.type != .board })
        temps.append(info)
        infos = temps
        selectedInfo = info
        updateInfo(shouldAutoChangeToSpeakerMode: true)
    }
    
    func removeWhiteBoardInfoIfNeed() {
        Log.info(text: "removeShareInfoIfNeed1")
        if infos.filter({ $0.type != .av }).count == 0 { return }
        Log.info(text: "removeShareInfoIfNeed2")
        let temps = infos.filter({ $0.type == .av })
        infos = temps
        selectedInfo = nil
        updateInfo(shouldAutoChangeToSpeakerMode: true)
    }
    
    func renderBoardView(boardView: UIView, info: MeetingVM.Info, writable: Bool) {
        guard lastRenderBoardId != info.boardInfo.boardId else {
            return
        }
        lastRenderBoardId = info.boardInfo.boardId
        whiteBoardManager.initWhiteSDK(boardView, dataSourceDelegate: self)
        whiteBoardManager.joinWhiteRoom(withBoardId: info.boardInfo.boardId,
                                        boardToken: info.boardInfo.boardToken,
                                        whiteWriteModel: false) {
            Log.info(text: "whiteBoardManager joinWhiteRoom")
        } completeFail: { (error) in
            if let e = error { Log.debug(text: e.localizedDescription) }
        }
        boardView.isUserInteractionEnabled = true
    }
    
    func renderBoardView(view: UIView,
                         boardId: String,
                         boardToken: String,
                         writable: Bool) {
        lastRenderBoardId = boardId
        whiteBoardManager.initWhiteSDK(view, dataSourceDelegate: self)
        whiteBoardManager.joinWhiteRoom(withBoardId: boardId,
                                        boardToken: boardToken,
                                        whiteWriteModel: false) {
            Log.info(text: "whiteBoardManager joinWhiteRoom")
        } completeFail: { (error) in
            if let e = error { Log.debug(text: e.localizedDescription) }
        }
    }
    
    
    func emitedBoardVCType() {
        guard let selected = selectedInfo else {
            return
        }
        
        let boardId = selected.boardInfo.boardId
        let boardToken = selected.boardInfo.boardToken
        let userId = selected.user.userId
        let roomId = loginInfo.roomId
         
        if selected.isMe {
            let info = WhiteBoardVM.Info(boardId: boardId, boardToken: boardToken, role: .owner, roomId: roomId, userId: userId)
            invokeMeetingVMShouldShowWhitwBoardVC(info: info)
            return
        }
        if let boardInfo = ARConferenceManager.getScene().readBoardInfo() {
            if boardInfo.state.grantUsers.contains(localUser.info.userId) {
                let info = WhiteBoardVM.Info(boardId: boardId, boardToken: boardToken, role: .interactor, roomId: roomId, userId: userId)
                invokeMeetingVMShouldShowWhitwBoardVC(info: info)
            }
            else {
                let info = WhiteBoardVM.Info(boardId: boardId, boardToken: boardToken, role: .audience, roomId: roomId, userId: userId)
                invokeMeetingVMShouldShowWhitwBoardVC(info: info)
            }
        }
        
    }
    
    func closeWhiteBoard() {
        let sceneInfo =  ARConferenceManager.getScene().info
        let param = HMReqParamsHostAbondon()
        param.roomId = sceneInfo.sceneId
        param.userId = ARConferenceManager.getLocalUser().info.userId
        invokeMeetingVMShouldShowLoading()
        HttpManager.requestWhiteBoardStop(withParam: param) { [weak self] in
            self?.invokeMeetingVMShouldDismissLoading()
        } failure: { [weak self](error) in
            self?.invokeMeetingVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
}

extension MeetingVM: WhiteManagerDelegate {
    
}
