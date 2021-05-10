//
//  ChannelMesssage.swift
//  VideoConference
//
//  Created by ZYP on 2021/4/9.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation



struct ChannelMesssageCloseAllCaremaMic: Decodable {

    let cmd: Int
    let data: MsgData
    
    static func instance(jsonString: String) -> ChannelMesssageCloseAllCaremaMic? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        let dec = JSONDecoder()
        do {
            return try dec.decode(ChannelMesssageCloseAllCaremaMic.self, from: data)
        } catch let e {
            Log.error(error: e)
            return nil
        }
    }
    
    struct MsgData: Decodable {
        let device: Int
        
        var deviceType: Device {
            return Device(rawValue: device)!
        }
        
        enum Device: Int {
            case camera = 1
            case mic = 2
        }
    }
    
    
}
/** "{\"cmd\":2,\"data\":{\"device\":1}}" **/

