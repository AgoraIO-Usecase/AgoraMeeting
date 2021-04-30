//
//  MeetingVM+VideoInfo.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/12.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte
import AgoraRoom
import DifferenceKit

extension MeetingVM {
    
    enum RoutingType {
        case speaker
        case headSet
        case earpiece
    }
    
    struct Info: Equatable {
        
        let type: InfoType
        var user: User
        var avInfo: AVInfo
        let boardInfo: ShareBoardInfo
        var screenInfo: ShareScreenInfo
        var isSelected = false
        let addTime = Date().timeIntervalSince1970
        
        private var upType = UpType.none
        /// time stamp, when set upType as up or down
        private var opTimeInterval: TimeInterval = 0.0
        
        init(type: InfoType, user: User, avInfo: AVInfo) {
            self.type = type
            self.user = user
            self.avInfo = avInfo
            self.boardInfo = .empty
            self.screenInfo = .empty
        }
        
        init(type: InfoType, user: User, boardInfo: ShareBoardInfo) {
            self.type = type
            self.user = user
            self.avInfo = .empty
            self.boardInfo = boardInfo
            self.screenInfo = .empty
        }
        
        init(type: InfoType, user: User, screenInfo: ShareScreenInfo) {
            self.type = type
            self.user = user
            self.avInfo = .empty
            self.boardInfo = .empty
            self.screenInfo = screenInfo
        }
        
        var streamId: String {
            switch type {
            case .av:
                return avInfo.streamId
            case .screen:
                return screenInfo.streamId
            case .board:
                return ""
            }
        }
        
        var hasVideo: Bool {
            switch type {
            case .av:
                return avInfo.streamType == .audioAndVideo || avInfo.streamType == .video
            case .board:
                return false
            case .screen:
                return true
            }
        }

        var hasAudio: Bool {
            switch type {
            case .av:
                return avInfo.streamType == .audioAndVideo || avInfo.streamType == .audio
            case .board:
                return false
            case .screen:
                return false
            }
        }

        var isHost: Bool {
            return user.userRole == "host"
        }

        var headImageName: String {
            return String.headImageName(userName: user.userName.md5())
        }

        var isMe: Bool {
            return user.userId == ARConferenceManager.getLocalUser().info.userId
        }
        
        var localUserIsHost: Bool {
            let res = ARConferenceManager.getLocalUser().info.userRole == "host"
            return res
        }
        
        var isShare: Bool {
            return type != .av
        }
        
        var shouldRenderVideoInCell = true
        var shouldRenderBoardInCell = true
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            if lhs.type != rhs.type { return false }
            switch lhs.type {
            case .av:
                return lhs.user.userId == rhs.user.userId
            case .board:
                return lhs.boardInfo.boardId == rhs.boardInfo.boardId
            case .screen:
                return lhs.screenInfo.streamId == lhs.screenInfo.streamId
            }
        }
        
        mutating func setUpType(type: UpType) {
            self.upType = type
            if type != .none {
                self.opTimeInterval = Date().timeIntervalSince1970
            }
        }
        
        mutating func setOpTime(time: TimeInterval) {
            self.opTimeInterval = time
        }
        
        mutating func setUpTypeReserve() {
            let type: UpType = getUpType == .none ? .up : (getUpType == .up ? .down : .up)
            setUpType(type: type)
        }
        
        var getUpType: UpType {
            return upType
        }
        
        var getOpTime: TimeInterval {
            return opTimeInterval
        }
    }
    
    struct BottomItemUpdateInfo {
        let dataType: DataType
        let updateType: UpdateType
        let timeCount: Int
        
        enum DataType {
            case video
            case audio
        }
        
        enum UpdateType: NSInteger {
            case active = 0
            case inActive = 1
            case time = 2
        }
    }
    
    var setVCInfo: SetVC.Info {
        let roomName = loginInfo.roomName
        let roomPsd = loginInfo.password
        let headImageName = String.headImageName(userName: loginInfo.userName.md5())
        let userName = loginInfo.userName
        let userRole = localUser.info.userRole
        let userPermission = ARConferenceManager.getScene().readUserPermission()
        let openVideoShoudApprove = userPermission?.videoOpenShouldApply ?? false
        let openAudioShoudApprove = userPermission?.audioOpenShouldApply ?? false
        let beauty = false
        let ai = false
        let inOutNotiType = ARUserDefaults.getNotiTypeValue()
        let userId = loginInfo.userId
        let roomId = loginInfo.roomId
        return SetVC.Info(roomId: roomId,
                          roomName: roomName,
                          roomPsd: roomPsd,
                          userName: userName,
                          userId: userId,
                          userRole: userRole,
                          headImageName: headImageName,
                          openVideoShoudApprove: openVideoShoudApprove,
                          openAudioShoudApprove: openAudioShoudApprove,
                          beauty: beauty,
                          ai: ai,
                          inOutNotiType: inOutNotiType)
    }
    
    
    
}

extension MeetingVM.Info {
    enum UpType {
        case none
        case up
        case down
    }
    
    struct ShareBoardInfo {
        let boardId: String
        let boardToken: String
        let flow: Bool
        let gentUsersIds: [String]
        
        static var empty: ShareBoardInfo {
            return ShareBoardInfo(boardId: "", boardToken: "", flow: false, gentUsersIds: [])
        }
    }
    
    struct ShareScreenInfo {
        var streamId: String
        
        static var empty: ShareScreenInfo {
            return ShareScreenInfo(streamId: "")
        }
        
        mutating func setStreamId(id: String) {
            self.streamId = id
        }
    }
    
    struct AVInfo {
        var streamId: String
        var streamType: AgoraRteMediaStreamType
        
        static var empty: AVInfo {
            return AVInfo(streamId: "", streamType: .none)
        }
        
        mutating func setStreamType(streamType: AgoraRteMediaStreamType) {
            self.streamType = streamType
        }
        
        mutating func setStreamId(id: String) {
            self.streamId = id
        }
    }
    
    struct User {
        let userId: String
        let userName: String
        var userRole: String!
        
        mutating func setUserRole(role: String) {
            self.userRole = role
        }
    }
    
    enum InfoType: UInt {
        case av = 0
        case screen = 1
        case board = 2
        
        var descirption: String {
            switch self {
            case .av:
                return "av"
            case .board:
                return "board"
            case .screen:
                return "screen"
            }
        }
    }
}

extension MeetingVM {
    struct MoreAlertShowInfo {
        let canCloseAllAudio: Bool
        let canCloseAllVideo: Bool
        let canStartScreen: Bool
        let canEndScreen: Bool
    }
}

extension MeetingVM {
    struct UpdateInfo: Equatable {
        let originalInfos: [Info]
        var videoCellInfos: [VideoCell.Info]
        let audioCellInfos: [AudioCellInfo]
        var videoCellMiniInfos: [VideoCellMini.Info]
        let mode: MeetingViewMode
        let speakerInfo: SpeakerModel?
        let showRightButton: Bool
        let selectedInfo: Info?
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            if lhs.mode != rhs.mode { return false }
            switch lhs.mode {
            case .videoFlow:
                return lhs.videoCellInfos == rhs.videoCellInfos
            case .audioFlow:
                return lhs.audioCellInfos == rhs.audioCellInfos
            case .speaker:
                let result = lhs.showRightButton == rhs.showRightButton
                var other = true
                if lhs.speakerInfo == nil && rhs.speakerInfo == nil {
                    other = true
                }
                if lhs.speakerInfo != nil && rhs.speakerInfo == nil {
                    other = false
                }
                
                if lhs.speakerInfo == nil && rhs.speakerInfo != nil {
                    other = false
                }
                if lhs.speakerInfo != nil && rhs.speakerInfo != nil {
                    other = lhs.speakerInfo!.isEqualToModel(rhs.speakerInfo!)
                }
                return result && other
            @unknown default:
                fatalError()
            }
        }
        
        static var empty: UpdateInfo {
            return UpdateInfo(originalInfos: [],
                              videoCellInfos: [],
                              audioCellInfos: [],
                              videoCellMiniInfos: [],
                              mode: .videoFlow,
                              speakerInfo: nil,
                              showRightButton: false,
                              selectedInfo: nil)
            
            
        }
        
        struct Update<Element: Equatable>: Equatable {
            let updates: [Element]
            let adds: [Element]
            let deletes: [Element]
            
            static var empty: Update<Element> {
                return Update<Element>(updates: [], adds: [], deletes: [])
            }
            
            static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.updates == rhs.updates &&
                    lhs.adds == rhs.adds &&
                    lhs.deletes == rhs.deletes
            }
        }
        
    }
    
    
    struct AudioCellInfo: Equatable, Differentiable {
        let headImageName: String
        let name: String
        let audioEnable: Bool
        let userId: String
        
        var differenceIdentifier: String {
            return userId
        }
        
        func isContentEqual(to source: MeetingVM.AudioCellInfo) -> Bool {
            let rhs = source
            return headImageName == rhs.headImageName &&
                name == rhs.name &&
                audioEnable == rhs.audioEnable
        }
    }
}

extension SpeakerModel {
    func isEqualToModel(_ model: SpeakerModel) -> Bool {
        return model.name == name &&
            model.hasAudio == hasAudio &&
            model.isHost == isHost &&
            model.isLocalUser == isLocalUser &&
            model.type == type
    }
}

extension VideoCellMini.Info: Differentiable {
    typealias DifferenceIdentifier = String
    
    var differenceIdentifier: String {
        return userId + "\(type.rawValue)"
    }
    
    func isContentEqual(to source: VideoCellMini.Info) -> Bool {
        let rhs = source
        return isHost == rhs.isHost &&
            enableAudio == rhs.enableAudio &&
            name == rhs.name &&
            headImageName == rhs.headImageName &&
            showHeadImage == rhs.showHeadImage &&
            hasDisplayInMainScreen == rhs.hasDisplayInMainScreen &&
            type == rhs.type &&
            isMe == rhs.isMe &&
            streamId == rhs.streamId &&
            board == rhs.board
    }
}

extension VideoCell.Info: Differentiable {
    var differenceIdentifier: String {
        return userId
    }
    
    func isContentEqual(to source: VideoCell.Info) -> Bool {
        return isHost == source.isHost &&
            isUp == source.isUp &&
            enableAudio == source.enableAudio &&
            name == source.name &&
            showMeunButton == source.showMeunButton &&
            headImageName == source.headImageName &&
            showHeadImage == source.showHeadImage &&
            streamId == source.streamId &&
            sheetInfos == source.sheetInfos
    }
}

