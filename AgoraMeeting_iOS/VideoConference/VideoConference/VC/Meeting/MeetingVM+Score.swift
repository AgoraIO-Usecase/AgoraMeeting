//
//  MeetingVM+Score.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/25.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraSceneStatistic
import AgoraRoom

extension MeetingVM {
    func submitScore(score: ASScore) {
        service.context = AgoraSceneStatisticContext()
        service.context.os = "ios"
        service.context.device = getDeviceInfo() ?? "unknow"
        service.context.app = "Agora Meeting"
        service.context.useCase = "meeting"
        service.context.userId = "testUserId"
        service.context.sessionId = "testSessionId"
        let values = [AgoraUserRatingValue(type: .callQuality, value: CGFloat(score.value1)),
                      AgoraUserRatingValue(type: .functionCompleteness, value: CGFloat(score.value2)),
                      AgoraUserRatingValue(type: .generalExperience, value: CGFloat(score.value3))]
        let scene = ARConferenceManager.getScene()
        service.userRating(values, comment: score.text) { [weak self] in
            scene.leave()
            self?.invokeMeetingVMDidLeaveRoom()
            Log.info(text: "success", tag: "submitScore")
        } fail: { [weak self](code) in
            scene.leave()
            Log.errorText(text: "code: \(code)", tag: "submitScore")
            self?.invokeMeetingVMDidLeaveRoom()
        }
    }
    
    func handleScoreDismiss() {
        let scene = ARConferenceManager.getScene()
        scene.leave()
        invokeMeetingVMDidLeaveRoom()
    }
    
    func getDeviceInfo() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        guard let bundlePath = Bundle.main.path(forResource: "DeviceInfo", ofType: "plist"), let dicData = NSDictionary(contentsOfFile: bundlePath) else {
            return platform
        }
        guard let plat = dicData[platform] as? String else {
            return platform
        }
        return plat
    }
    
}
