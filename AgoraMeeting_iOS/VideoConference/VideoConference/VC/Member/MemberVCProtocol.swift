//
//  MemberVCProtocol.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/8.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

protocol MemberVCDelegate: NSObject {
    func memberVCShouldStartVideoTimer()
    func memberVCShouldStartAudioTimer()
    func memberVCDidRequestHostError(error: NSError)
}
