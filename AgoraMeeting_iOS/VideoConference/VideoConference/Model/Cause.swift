//
//  Cause.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/24.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

struct Cause: Decodable {
    let cmd: Int
    let data: String?
    
    static func decode(jsonString: String) throws -> Cause {
        let d = JSONDecoder()
        return try d.decode(Cause.self, from: jsonString.data(using: .utf8)!)
    }
    
    var getCmd: Cmd? {
        return Cmd(rawValue: cmd)
    }
    
    enum Cmd: Int {
        /// 关闭所有的摄像头设备
        case closeAllCameraDevices = 300
        /// 关闭所有的麦克风设备
        case closeAllMicDevices = 301
        /// 关闭单人的摄像头设备
        case closeSingleCameraDevices = 302
        /// 关闭单人的麦克风设备
        case closeSingleMicDevices = 303
        /// 房间的权限有改变
        case userPermissionChanged = 310
        /// 发起白板
        case startBoard = 320
        /// 关闭白板
        case closeBoard = 321
        /// 开启屏幕共享
        case startScreenShare = 322
        /// 关闭屏幕共享
        case closeScreenShare = 323
        /// 开启屏幕录制
        case startRecord = 330
        /// 关闭屏幕录制
        case closeRecord = 331
        /// 申请白板互动(使用公共属性，需要进一步查看 grantUsers
        case boardInteracts = 2
        /// 结束房间
        case endRoom = 4
    }
}
