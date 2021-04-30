//
//  LoginVM+Log.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/19.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRoom

extension LoginVM {
    func logWhenLoginSuccess() {
        var str = ""
        var dic = [String : String]()
        let entryParams = ARConferenceManager.getEntryParams()
        let addResp = ARConferenceManager.getAddRoomResp()
        
        dic["userName"] = entryParams.userName
        dic["userUuid"] = entryParams.userUuid
        dic["roomName"] = entryParams.roomName
        dic["roomUuid"] = entryParams.roomUuid
        dic["password"] = entryParams.password
        dic["appId"] = entryParams.appId
        dic["streamId"] = addResp.streamId
        dic["userRole"] = addResp.userRole
        
        str += "\(dic)"
        let tag = "LoginVM Login Success"
        
        Log.info(text: str, tag: tag)
    }
}
