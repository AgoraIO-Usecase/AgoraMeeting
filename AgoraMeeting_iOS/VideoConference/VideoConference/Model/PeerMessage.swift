//
//  PeerMessage.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/25.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

struct PeerMessage: Decodable {

    let cmd: Int
    let data: MsgData
    
    static func instance(jsonString: String) -> PeerMessage? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        let dec = JSONDecoder()
        do {
            return try dec.decode(PeerMessage.self, from: data)
        } catch let e {
            Log.error(error: e)
            return nil
        }
    }
    
    struct MsgData: Decodable {
        let processUuid: String
        let action: Int
        let fromUser: UserInfo
        
        var actionType: ActionType? {
            return ActionType(rawValue: action)
        }
    }
    
    struct UserInfo: Decodable {
        let userUuid: String
        let userName: String
        let role: String
    }
    
    enum ActionType: Int {
        // request
        case req
        case invite
        case accept
        case reject
        case cancle
    }
}
