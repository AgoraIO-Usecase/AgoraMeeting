//
//  MeetingVM+Data+Remote.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/9.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte
extension MeetingVM {
    
    func addRemoteUserInfo(events: [AgoraRteUserEvent], scene: AgoraRteScene) {
        var temp = [Info]()
        let esitUserIds = infos.filter({ $0.type == .av }).map({ $0.user.userId })
        let streams = scene.streams
        for e in events {
            let userId = e.modifiedUser.userId
            if esitUserIds.contains(userId) { continue }
            
            let userName = e.modifiedUser.userName
            let userRole = e.modifiedUser.userRole
            let user = Info.User(userId: userId,
                                 userName: userName,
                                 userRole: userRole)
            let stream = streams.filter({ $0.owner.userId == userId && $0.streamName == "" }).first
            let streamId = stream?.streamId ?? ""
            let streamType = stream?.streamType ?? .none
            let avInfo = Info.AVInfo(streamId: streamId, streamType: streamType)
            let info = Info(type: .av, user: user, avInfo: avInfo)
            temp.append(info)
        }
        infos.append(contentsOf: temp)
        fetchScreenShareInRemoteUserAdd(events: events, scene: scene)
        addEnterRoomNoti(events: events)
    }
    
    func removeRemoteUsersInfo(events: [AgoraRteUserEvent]) {
        let rvms = events.map({ $0.modifiedUser.userId })
        infos.removeAll { (info) -> Bool in
            switch info.type {
            case .board:/* board info whould never be removed when it`s owner be removed **/
                return false
            default:
                let res = rvms.contains(info.user.userId)
                if res, info.type != .board {
                    unsubscribe(infos: [info])
                }
                return res
            }
        }
        addLeaveRoomNoti(events: events)
    }
    
    func updateRemoteUserInfo(event: AgoraRteUserEvent) {
        let user = event.modifiedUser
        for i in 0..<infos.count {
            if infos[i].type == .av {
                if user.userId == infos[i].user.userId, infos[i].type == .av {
                    infos[i].user.setUserRole(role: user.userRole)
                    continue
                }
            }
        }
    }
    
    func updateRemoteUserProperties(changedProperties: [String], user: AgoraRteUserInfo) {
        if changedProperties.contains("dirty") {/// will remove av/board\screen
            infos = infos.filter({ $0.user.userId != user.userId})
        }
    }
    
    func addRemoteStreams(events: [AgoraRteMediaStreamEvent]) {
        let count = infos.count
        let avEvents = events.filter({ $0.modifiedStream.streamName == "" })
        let screenShareEvent = events.filter({ $0.modifiedStream.streamName == "ScreenShare" }).first
        for e in avEvents {
            for i in 0..<count {
                let streamId = e.modifiedStream.streamId
                let streamType = e.modifiedStream.streamType
                if infos[i].type == .av, infos[i].user.userId == e.modifiedStream.owner.userId {
                    infos[i].avInfo.setStreamId(id: streamId)
                    infos[i].avInfo.setStreamType(streamType: streamType)
                    break
                }
            }
        }
        
        if let `screenShareEvent` = screenShareEvent, !infos.hasShareType {
            let owner = screenShareEvent.modifiedStream.owner
            let user = Info.User(userId: owner.userId, userName: owner.userName, userRole: owner.userRole)
            let screenInfo = Info.ShareScreenInfo(streamId: screenShareEvent.modifiedStream.streamId)
            let info = Info(type: .screen, user: user, screenInfo: screenInfo)
            infos.append(info)
        }
    }
    
    func removeRemoteStreams(events: [AgoraRteMediaStreamEvent]) {
        let rvms = events.map({ $0.modifiedStream.streamId })
        let count = infos.count
        for i in 0..<count {
            if infos[i].type == .av, rvms.contains(infos[i].streamId) {
                unsubscribe(infos: [infos[i]])
                infos[i].avInfo = .empty
            }
        }
        
        let screenShareEvent = events.filter({ $0.modifiedStream.streamName == "ScreenShare" }).first
        if screenShareEvent != nil {
            let temp = infos
            if let info = temp.filter({ $0.type == .screen }).first {
                unsubscribe(infos: [info])
            }
            infos = temp.filter({ $0.type != .screen })
        }
    }
    
    func updateRemoteStreams(events: [AgoraRteMediaStreamEvent]) {
        for e in events {
            for i in 0..<infos.count {
                if e.modifiedStream.streamName == "ScreenShare" {
                    if infos[i].type == .screen {
                        if e.modifiedStream.owner.userId == infos[i].user.userId {
                            infos[i].screenInfo.setStreamId(id: e.modifiedStream.streamId)
                            break
                        }
                    }
                }
                else {
                    if infos[i].type == .av {
                        if e.modifiedStream.owner.userId == infos[i].user.userId {
                            infos[i].avInfo.setStreamType(streamType: e.modifiedStream.streamType)
                            infos[i].avInfo.setStreamId(id: e.modifiedStream.streamId)
                            break
                        }
                    }
                }
            }
        }
    }
    
    
}
