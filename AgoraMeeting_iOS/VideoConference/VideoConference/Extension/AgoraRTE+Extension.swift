//
//  AgoraRTE+Extension.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/22.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte

extension AgoraRteUserInfo {
    var isHost: Bool {
        return userRole == "host"
    }
}

extension AgoraRteScene {
    
    func readUserPermission() -> UserPermission? {
        return AgoraRteScene.readUserPermission(properties: properties)
    }
    
    static func readUserPermission(properties: [String : Any]?) -> UserPermission? {
        let dict = properties
        guard let userPermission = dict?["userPermission"] as? [String : Any] else {
            return nil
        }
        guard let micAccess = userPermission["micAccess"] as? Bool else {
            return nil
        }
        guard let cameraAccess = userPermission["cameraAccess"] as? Bool else {
            return nil
        }
        return UserPermission(micAccess: micAccess, cameraAccess: cameraAccess)
    }
    
    func readSchedule() -> Schedule? {
        let dict = properties
        guard let schedule = dict?["schedule"] as? [String : Any] else {
            return nil
        }
        guard let state = schedule["state"] as? Int32 else {
            return nil
        }
        guard let startTime = schedule["startTime"] as? Int32 else {
            return nil
        }
        guard let duration = schedule["duration"] as? Int32 else {
            return nil
        }
        return Schedule(state: Schedule.RoomState(rawValue: state)!, startTime: startTime, duration: duration)
    }
    
    func readBoardInfo() -> Board? {
        let dict = properties
        guard let board = dict?["board"] as? [String : Any] else {
            return nil
        }
        guard let info = board["info"] as? [String : Any] else {
            return nil
        }
        guard let boardId = info["boardId"] as? String else {
            return nil
        }
        guard let boardToken = info["boardToken"] as? String else {
            return nil
        }
        guard let state = board["state"] as? [String : Any] else {
            return nil
        }
        guard let follow = state["follow"] as? Int else {
            return nil
        }
        guard let grantUsers = state["grantUsers"] as? [String] else {
            return nil
        }
        guard let ownerInfo = board["ownerInfo"] as? [String : Any] else {
            return nil
        }
        guard let userId = ownerInfo["userId"] as? String else {
            return nil
        }
        guard let userName = ownerInfo["userName"] as? String else {
            return nil
        }
        guard let userRole = ownerInfo["userRole"] as? String else {
            return nil
        }
        
        let userInfo = UserInfo(userId: userId, userName: userName, userRole: userRole)
        let boardState = Board.State(follow: follow, grantUsers: grantUsers)
        let boardinfo = Board.Info(boardId: boardId, boardToken: boardToken)
        return Board(ownerInfo: userInfo, state: boardState, info: boardinfo)
    }
    
    func readShareInfo() -> Share? {
        let dict = properties
        guard let share = dict?["share"] as? [String : Any] else {
            return nil
        }
        guard let type = share["type"] as? Int32 else {
            return nil
        }
        guard let screen = share["screen"] as? [String : Any] else {
            return Share(type: type, screen: nil)
        }
        
        guard let data = jsonToData(jsonDic: screen) else {
            return Share(type: type, screen: nil)
        }
        
        let decoder = JSONDecoder()
        do {
            let screen = try decoder.decode(Share.Screen.self, from: data)
            return Share(type: type, screen: screen)
        } catch let e {
            assert(true, "can not decode")
            Log.errorText(text: e.localizedDescription)
            return Share(type: type, screen: nil)
        }
    }
    
    func jsonToData(jsonDic: [String : Any]) -> Data? {
        if (!JSONSerialization.isValidJSONObject(jsonDic)) {
            Log.errorText(text: "is not a valid json object")
            Log.errorText(text: jsonDic.description)
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: [])
        return data
    }

    
    struct UserPermission {
        fileprivate let micAccess: Bool
        fileprivate let cameraAccess: Bool
        
        var videoOpenShouldApply: Bool {
            return !cameraAccess
        }
        
        var audioOpenShouldApply: Bool {
            return !micAccess
        }
    }
    
    struct Schedule {
        let state: RoomState
        let startTime: Int32
        let duration: Int32
        
        enum RoomState: Int32 {
            case prepare = 0
            case starting = 1
            case end = 2
        }
    }
    
    struct UserInfo: Decodable {
        let userId: String
        let userName: String
        let userRole: String
    }
    
    struct Board {
        let ownerInfo: UserInfo
        let state: State
        let info: Info
        
        struct State {
            let follow: Int
            let grantUsers: [String]
        }
        
        struct Info {
            let boardId: String
            let boardToken: String
        }
    }
    
    struct Share: Decodable {
        let type: Int32
        let screen: Screen?
        
        struct Screen: Decodable {
            let ownerInfo: UserInfo
            let streamInfo: StreamInfo
            
            struct StreamInfo: Decodable {
                let streamId: String
            }
        }
        
        var getType: ShareType {
            return ShareType(rawValue: type)!
        }
        
        enum ShareType: Int32 {
            case not = 0
            case screen = 1
            case whiteBoard = 2
        }
    }
    
    struct ScreenShareInfo {
        let screenId: String
        let userId: String
        let userName: String
        let userRole: String
    }
    
}

extension AgoraRteMediaStreamType {
    var hasVideo: Bool {
        return self == .video || self == .audioAndVideo
    }
    
    var hasAudio: Bool {
        return self == .audio || self == .audioAndVideo
    }
}


