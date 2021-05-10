//
//  LoginInfo+Extension.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/14.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
extension LoginVM.Info {
    var toMeetingBottomInfo: MeetingBottomInfo {
        let info = MeetingBottomInfo()
        info.audioEnable = enableAudio
        info.videoEnable = enableVideo
        return info
    }
}
