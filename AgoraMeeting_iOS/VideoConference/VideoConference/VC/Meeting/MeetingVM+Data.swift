//
//  MeetingVM+Data.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/23.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte
import AgoraRoom

extension MeetingVM {
    
    /// manual set mode for speak
    func setSpeakerModeWithInfo(info: Info) {
        if info.type == .av, !info.hasVideo { return }
        if let selected = selectedInfo {
            unsubscribe(infos: [selected], onlyVideo: true)
        }
        selectedInfo = info
        let model = getSpeakerModel()!
        setMode(mode: .speaker)
        updateInfo()
        let hidden = info.type != .board
        invokeMeetingVMShouldUpdateSpeakerView(info: info, model: model)
        invokeMeetingVMShouldChangeBoardButtonHidden(hidden: hidden)
    }
    
    func setSpeakerModeWithInfo(info: VideoCell.Info) {
        let temp = infos
        if let info = temp.filter({ $0.user.userId == info.userId && $0.type == .av }).first {
            setSpeakerModeWithInfo(info: info)
        }
    }
    
    func setSpeakerModeWithInfo(info: VideoCellMini.Info) {
        let type = Info.InfoType(rawValue: UInt(info.type.rawValue))!
        let temp = infos
        if let info = temp.filter({ $0.user.userId == info.userId && $0.type == type }).first {
            setSpeakerModeWithInfo(info: info)
        }
    }
    
    func setVideoMode() {
        if let selected = selectedInfo {
            unsubscribe(infos: [selected], onlyVideo: true)
        }
        selectedInfo = nil
        setMode(mode: .videoFlow)
        updateInfo()
    }
    
    func getSpeakerModel() -> SpeakerModel? {
        if let selected = selectedInfo {
            let isLocalUser = selected.isMe
            let model = SpeakerModel()
            model.hasAudio = selected.hasAudio
            switch selected.type {
            case .board:
                model.type = .board
            case .av:
                model.type = .video
            case .screen:
                model.type = .screen
            }
            model.isHost = selected.isHost
            model.name = selected.user.userName
            model.isLocalUser = isLocalUser
            return model
        }
        return nil
    }
    
    func fetchInfos() -> [Info] {
        let users = ARConferenceManager.getScene().users
        let streams = ARConferenceManager.getScene().streams
        Log.debug(text: "fetchInfos start \(streams.count)", tag: "fetchInfos")
        var news = users.map({ u -> Info in
            let userId = u.userId
            let userName = u.userName
            let userRole = u.userRole
            let user = Info.User(userId: userId, userName: userName, userRole: userRole)
            Log.debug(text: "\(userName)", tag: "fetchInfos")

            if let stream = streams.filter({ $0.streamId == u.streamId }).first {
                let avInfo = Info.AVInfo(streamId: stream.streamId, streamType: stream.streamType)
                return Info(type: .av, user: user, avInfo: avInfo)
            }

            return Info(type: .av, user: user, avInfo: .empty)
        })
        
        if !news.hasContainLocalUser(userId: localUser.info.userId, type: .av) {
            let userId = localUser.info.userId
            let userName = localUser.info.userName
            let userRole = localUser.info.userRole
            let user = Info.User(userId: userId, userName: userName, userRole: userRole)
            let info = Info(type: .av, user: user, avInfo: .empty)
            news.append(info)
        }
        
        if let stream = streams.filter({ $0.streamName != "" }).first {
            let userId = stream.owner.userId
            let userName = stream.owner.userName
            let userRole = stream.owner.userRole
            let user = Info.User(userId: userId, userName: userName, userRole: userRole)
            let screenInfo = Info.ShareScreenInfo(streamId: stream.streamId)
            let info = Info(type: .screen, user: user, screenInfo: screenInfo)
            news.append(info)
        }

        return news
    }
    
    func setUpOrDown(targetUserId: String) {
        for i in 0..<infos.count {
            if infos[i].user.userId == targetUserId {
                var info = infos[i]
                info.setUpTypeReserve()
                infos[i] = info
                break
            }
        }
        updateInfo()
    }
    
    func checkLocalUserHasShare() {
        let scene = ARConferenceManager.getScene()
        let userId = localUser.info.userId
        if let shareInfo = scene.readShareInfo() {
            let type = shareInfo.getType
            switch type {
            case .not:
                invokeMeetingVMShouldShowEndRoomAlert()
                break
            case .whiteBoard:
                guard let boardInfo = scene.readBoardInfo() else {
                    invokeMeetingVMShouldShowEndRoomAlert()
                    return
                }
                let boardInfUserId = boardInfo.ownerInfo.userId
                guard boardInfUserId == userId else {
                    invokeMeetingVMShouldShowEndRoomAlert()
                    return
                }
                invokeMeetingVMShouldShowEndWhiteBoardAlert()
                break
            case .screen:
                guard let screenUserId = shareInfo.screen?.ownerInfo.userId, screenUserId == userId else {
                    invokeMeetingVMShouldShowEndRoomAlert()
                    return
                }
                invokeMeetingVMShouldShowEndScreenAlert()
                break
            }
        }
        invokeMeetingVMShouldShowEndRoomAlert()
    }
    
    func updateInfo(shouldAutoChangeToSpeakerMode: Bool = false) {
        
        /// auto set mode as speaker
        if shouldAutoChangeToSpeakerMode, getMode() != .speaker {
            let boardOrShareInfos = infos.filter({ $0.type != .av })
            if boardOrShareInfos.count > 0, let boardOrShareInfo = boardOrShareInfos.first {
                selectedInfo = boardOrShareInfo
                setMode(mode: .speaker)
            }
        }
        
        /// set attribute for ui
        var infosCopy = makeUIAttributeInfos()
        subscribeAudio(infos: infosCopy)
        /// sort infs
        infosCopy.sort(by: sortHandle(lhs:rhs:))
        infos = infosCopy
        
        switch getMode() {
        case .speaker:
            if var selected = selectedInfo, infos.contains(selected) {
                if infosCopy.count == 0 { /* infos is empty, will never excute, avoid unexcept event */
                    selectedInfo = nil
                    setMode(mode: .videoFlow)
                    let uiInfos = convertVideoCellInfo(originalInfos: infosCopy)
                    let videoCellMiniInfos = convertVideoCellMiniInfos(originalInfos: infosCopy, selectedInfo: selectedInfo)
                    let audioCellInfos = convertAudioCellInfo(originalInfos: infosCopy)
                    let update = UpdateInfo(originalInfos: infosCopy,
                                            videoCellInfos: uiInfos,
                                            audioCellInfos: audioCellInfos,
                                            videoCellMiniInfos: videoCellMiniInfos,
                                            mode: .speaker,
                                            speakerInfo: nil,
                                            showRightButton: false,
                                            selectedInfo: selectedInfo)
                    invokeMeetingVMDidUpdateInfos(updateInfo: update)
                }
                else if !infosCopy.contains(selected) { /* selectedInfo be removed */
                    selectedInfo = infosCopy.first
                    setSpeakerModeWithInfo(info: selectedInfo!)
                    let hidden = selected.type != .board
                    let model = getSpeakerModel()
                    let temps = infosCopy.filter { (info) -> Bool in
                        if selected != info { return true }
                        return selected.isMe && selected.isShare
                    }
                    let showRightButton = infosCopy.hasShareType
                    let uiInfos = convertVideoCellInfo(originalInfos: temps)
                    let videoCellMiniInfos = convertVideoCellMiniInfos(originalInfos: temps, selectedInfo: selected)
                    let audioCellInfos = convertAudioCellInfo(originalInfos: temps)
                    let update = UpdateInfo(originalInfos: temps, videoCellInfos: uiInfos,
                                            audioCellInfos: audioCellInfos,
                                            videoCellMiniInfos: videoCellMiniInfos,
                                            mode: .speaker,
                                            speakerInfo: model,
                                            showRightButton: showRightButton,
                                            selectedInfo: selected)
                    invokeMeetingVMDidUpdateInfos(updateInfo: update)
                    invokeMeetingVMShouldChangeBoardButtonHidden(hidden: hidden)
                    if let model = model, let `selectedInfo` = selectedInfo {
                        invokeMeetingVMShouldUpdateSpeakerView(info: selectedInfo, model: model)
                        invokeMeetingVMShouldUpdateSpeakerView(info: selectedInfo, model: model)
                    }
                }
                else { /* has selectedInfo, update it */
                    if let updateInfo = infosCopy.filter({ selected == $0 }).first {
                        selectedInfo = updateInfo
                        selected = updateInfo
                    }
                    let hidden = selected.type != .board
                    let model = getSpeakerModel()
                    let temps = infosCopy.filter { (info) -> Bool in
                        if info == selected { return false }
                        if !info.isMe, info.isShare { return true }
                        if !info.isMe, !info.isShare { return true }
                        return true
                    }
                    let showRightButton = infosCopy.hasShareType
                    let uiInfos = convertVideoCellInfo(originalInfos: temps)
                    let videoCellMiniInfos = convertVideoCellMiniInfos(originalInfos: temps, selectedInfo: selected)
                    let audioCellInfos = convertAudioCellInfo(originalInfos: temps)
                    let update = UpdateInfo(originalInfos: temps,
                                            videoCellInfos: uiInfos,
                                            audioCellInfos: audioCellInfos,
                                            videoCellMiniInfos: videoCellMiniInfos,
                                            mode: .speaker,
                                            speakerInfo: model,
                                            showRightButton: showRightButton,
                                            selectedInfo: selected)
                    invokeMeetingVMDidUpdateInfos(updateInfo: update)
                    invokeMeetingVMShouldChangeBoardButtonHidden(hidden: hidden)
                }
            }
            else { /* has not selected an info */
                let viewMode: MeetingViewMode = infosCopy.filter({ $0.hasVideo }).count == 0 ? .audioFlow : .videoFlow
                setMode(mode: viewMode)
                let uiInfos = convertVideoCellInfo(originalInfos: infosCopy)
                let videoCellMiniInfos = convertVideoCellMiniInfos(originalInfos: infosCopy, selectedInfo: nil)
                let audioCellInfos = convertAudioCellInfo(originalInfos: infosCopy)
                let update = UpdateInfo(originalInfos: infosCopy,
                                        videoCellInfos: uiInfos,
                                        audioCellInfos: audioCellInfos,
                                        videoCellMiniInfos: videoCellMiniInfos,
                                        mode: viewMode,
                                        speakerInfo: nil,
                                        showRightButton: false,
                                        selectedInfo: nil)
                invokeMeetingVMDidUpdateInfos(updateInfo: update)
            }
        case .videoFlow:
            let uiInfos = convertVideoCellInfo(originalInfos: infosCopy)
            let videoCellMiniInfos = convertVideoCellMiniInfos(originalInfos: infosCopy, selectedInfo: nil)
            let audioCellInfos = convertAudioCellInfo(originalInfos: infosCopy)
            let update = UpdateInfo(originalInfos: infosCopy,
                                    videoCellInfos: uiInfos,
                                    audioCellInfos: audioCellInfos,
                                    videoCellMiniInfos: videoCellMiniInfos,
                                    mode: .videoFlow,
                                    speakerInfo: nil,
                                    showRightButton: false,
                                    selectedInfo: nil)
            invokeMeetingVMDidUpdateInfos(updateInfo: update)
        case .audioFlow:
            let viewMode: MeetingViewMode = infosCopy.filter({ $0.hasVideo }).count == 0 ? .audioFlow : .videoFlow
            setMode(mode: viewMode)
            let uiInfos = convertVideoCellInfo(originalInfos: infosCopy)
            let videoCellMiniInfos = convertVideoCellMiniInfos(originalInfos: infosCopy, selectedInfo: nil)
            let audioCellInfos = convertAudioCellInfo(originalInfos: infosCopy)
            let update = UpdateInfo(originalInfos: infosCopy,
                                    videoCellInfos: uiInfos,
                                    audioCellInfos: audioCellInfos,
                                    videoCellMiniInfos: videoCellMiniInfos,
                                    mode: viewMode,
                                    speakerInfo: nil,
                                    showRightButton: false,
                                    selectedInfo: nil)
            invokeMeetingVMDidUpdateInfos(updateInfo: update)
        @unknown default:
            return
        }
        
        /** start timer when no video for 6s **/
        let hasVideo = infosCopy.filter({ $0.hasVideo }).count > 0
        hasVideo ? autoAudioModeChecker.stopRecord() : autoAudioModeChecker.startRecord()
    }
    
    func makeInfoForShowMoreAlert() {
        let screenInfo = infos.filter({ $0.type == .screen }).first
        let canCloseAllAudio = localUser.info.isHost
        let canCloseAllVideo = localUser.info.isHost
        let canStartScreen = screenInfo == nil || !screenInfo!.isMe
        let canEndScreen = screenInfo != nil && screenInfo!.isMe
        let info = MoreAlertShowInfo(canCloseAllAudio: canCloseAllAudio,
                                     canCloseAllVideo: canCloseAllVideo,
                                     canStartScreen: canStartScreen,
                                     canEndScreen: canEndScreen)
        invokeMeetingVMShouldShowMoreAlert(info: info)
    }
    
    private func makeUIAttributeInfos() -> [Info] {
        var infosCopy = [Info]()
        for var info in infos {
            if getMode() == .speaker, let selected = selectedInfo {
                if info.type == selected.type {
                    info.shouldRenderVideoInCell = info.user.userId != selected.user.userId
                }
                else {
                    info.shouldRenderVideoInCell = true
                }
                info.shouldRenderBoardInCell = !(info.type == .board && selected.user.userId == info.user.userId)
            }
            else {
                info.shouldRenderVideoInCell = true
            }
            if let selected = selectedInfo {
                info.isSelected = selected == info
            }
            else {
                info.isSelected = false
            }
            if (info.isMe || info.isHost), info.getUpType == .none { info.setUpType(type: .up) }
            infosCopy.append(info)
        }
        return infosCopy
    }
    
    private func sortHandle(lhs: Info, rhs: Info) -> Bool {
        /** up */
        if lhs.getUpType == .up, rhs.getUpType == .up {
            if lhs.isMe, !rhs.isMe {
                return true
            }
            if !lhs.isMe, rhs.isMe {
                return false
            }
            return lhs.getOpTime > rhs.getOpTime
        }
        if lhs.getUpType == .up {
            return true
        }
        if rhs.getUpType == .up {
            return false
        }
        
        /** down */
        if lhs.getUpType == .down, rhs.getUpType == .down {
            return lhs.getOpTime < rhs.getOpTime
        }
        if lhs.getUpType == .down, rhs.getUpType != .down {
            return lhs.getOpTime < rhs.addTime
        }
        if lhs.getUpType != .down, rhs.getUpType == .down {
            return lhs.addTime < rhs.getOpTime
        }
        
        /** share type */
        if lhs.type == .av, rhs.type != .av {
            return true
        }
        if lhs.type != .av, rhs.type == .av {
            return false
        }
        
        /** nromal */
        return lhs.addTime < rhs.addTime
    }
    
    public func handleSceneConntect(state: AgoraRteSceneConnectionState, error: AgoraRteError?) {
        if state == .fail, error != nil, error!.code == 20404100 { /** should leave room **/
            Log.info(text: "hasRecvRtmFailState, should leave room ")
            hasRecvRtmFailState = true
            invokeMeetingVMDidEndRoom()
            return
        }
        
        guard hasRecvRtmFailState == false else {
            return
        }
        
        if state == .connected { /** should reFecth data **/
            let oldInfos = infos
            let newInfos = fetchInfos()
            var temp = [Info]()
            for var info in newInfos {
                if let old = oldInfos.filter({ $0.user.userId == info.user.userId && $0.type == info.type }).first, old.getUpType != .none {
                    info.setUpType(type: old.getUpType)
                    info.setOpTime(time: old.getOpTime)
                }
                temp.append(info)
            }
            
            infos = temp
            updateButtomViewIfNeed()
            let scene = ARConferenceManager.getScene()
            fetchWhiteBoardInfo(scene:  scene)
            handleCheckScreenInfo(scene: scene)
            updateInfo(shouldAutoChangeToSpeakerMode: true)
        }
    }
    
    private func convertVideoCellInfo(originalInfos: [Info]) -> [VideoCell.Info] {
        let roomHasHost = originalInfos.hasHost
        let results = originalInfos.filter({ $0.type == .av })
        var temps = [VideoCell.Info]()
        for info in results {
            let showMeunButton = info.type == .av
            let name = info.user.userName
            
            var sheetInfos = [VideoCellSheetView.Info]()
            if info.isMe, info.isHost {
                let info = VideoCellSheetView.Info(actionType: .abandonHost)
                sheetInfos.append(info)
                
            }
            if info.isMe, !info.isHost{
                if !roomHasHost  {
                    let info = VideoCellSheetView.Info(actionType: .becomeHost)
                    sheetInfos.append(info)
                }
            }
            if !info.isMe, info.localUserIsHost {
                
                let info1 = VideoCellSheetView.Info(actionType: .closeAudio)
                let info2 = VideoCellSheetView.Info(actionType: .closeVideo)
                let info3 = VideoCellSheetView.Info(actionType: .setAsHost)
                let info4 = VideoCellSheetView.Info(actionType: .remove)
                
                info.hasAudio ? sheetInfos += [info1] : nil
                info.hasVideo ? sheetInfos += [info2] : nil
                
                sheetInfos += [info3, info4]
            }
            
            let uiInfo = VideoCell.Info(isHost: info.isHost,
                                        enableAudio: info.hasAudio,
                                        name: name,
                                        isUp: info.getUpType == .up,
                                        showMeunButton: showMeunButton,
                                        headImageName: info.headImageName,
                                        showHeadImage: !info.hasVideo,
                                        isMe: info.isMe,
                                        streamId: info.streamId,
                                        sheetInfos: sheetInfos,
                                        userId: info.user.userId)
            temps.append(uiInfo)
        }
        return temps
    }
    
    
    private func convertVideoCellMiniInfos(originalInfos: [Info], selectedInfo: Info?) -> [VideoCellMini.Info] {
        var temps = [VideoCellMini.Info]()
        for info in originalInfos {
            let hasDisplayInMainScreen = selectedInfo == nil ? false : (info == selectedInfo)
            
            let  board = VideoCellMini.Info.boardInfo(id: info.boardInfo.boardId,
                                                      token: info.boardInfo.boardToken)
                
            let uiInfo = VideoCellMini.Info(isHost: info.isHost,
                                            enableAudio: info.hasAudio,
                                            name: info.user.userName,
                                            headImageName: info.headImageName,
                                            showHeadImage: !info.hasVideo,
                                            hasDisplayInMainScreen: hasDisplayInMainScreen,
                                            type: VideoCellMini.Info.InfoType(rawValue: Int(info.type.rawValue))!,
                                            isMe: info.isMe,
                                            streamId: info.streamId,
                                            userId: info.user.userId,
                                            board: board)
            temps.append(uiInfo)
        }
        return temps
    }
    
    private func convertAudioCellInfo(originalInfos: [Info]) -> [AudioCellInfo] {
        var temps = [AudioCellInfo]()
        for info in originalInfos {
            let uiInfo = AudioCellInfo(headImageName: info.headImageName,
                                       name: info.user.userName,
                                       audioEnable: info.hasAudio,
                                       userId: info.user.userId)
            temps.append(uiInfo)
        }
        return temps
    }
    
    
}

extension MeetingVM: AutoAudioModeCheckerDelegate {
    
    func autoAudioModeCheckerShouldUpdateMode(recordTime: TimeInterval) {
        opQueue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            let currentMode = self.getMode()
            guard currentMode == .videoFlow else {
                return
            }
            self.selectedInfo = nil
            self.setMode(mode: .audioFlow)
            self.updateInfo(shouldAutoChangeToSpeakerMode: true)
        }
    }
    
}

