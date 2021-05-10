//
//  MeetingVM+Info+Extension.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/9.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

extension Array where Element == MeetingVM.Info {
    
    func hasContainLocalUser(userId: String, type: MeetingVM.Info.InfoType) -> Bool {
        contains { (info) -> Bool in
            return info.user.userId == userId && info.type == type
        }
    }
    
    var hasShareType: Bool {
        contains { (info) -> Bool in
            return info.type == .board || info.type == .screen
        }
    }
    
    var hasHost: Bool {
        return filter({ $0.isHost }).count > 0
    }
    
}
