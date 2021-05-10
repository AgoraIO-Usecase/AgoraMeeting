//
//  AutoAudioModeChecker.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/31.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

protocol AutoAudioModeCheckerDelegate: NSObject {
    func autoAudioModeCheckerShouldUpdateMode(recordTime: TimeInterval)
}

class AutoAudioModeChecker: NSObject {
    let source = TimerSource()
    var record: TimeInterval?
    let gap: TimeInterval = 6
    weak var delegate: AutoAudioModeCheckerDelegate?
    
    override init() {
        super.init()
        source.shouldEndSatrtWhenCountZero = false
        source.tag = 1
        source.delegate = self
        source.start(duratedCount: 10000)
    }
    
    func startRecord() {
        if record == nil {
            Log.info(text: "startRecord reset record", tag: "AutoAudioModeChecker")
            record = Date().timeIntervalSince1970
            return
        }
        
        Log.info(text: "startRecord", tag: "AutoAudioModeChecker")
    }
    
    func stopRecord() {
        record = nil
        Log.info(text: "stopRecord", tag: "AutoAudioModeChecker")
    }
    
    func invalied() {
        source.invalied()
        Log.info(text: "invalied", tag: "AutoAudioModeChecker")
    }
}

extension AutoAudioModeChecker: TimerSourceDelegate {
    func timerDidUpdate(timer: TimerSource, current count: Int) {
        guard let re = record else {
            Log.info(text: "timerDidUpdate not record", tag: "AutoAudioModeChecker")
            return
        }
        let currentGap = Date().timeIntervalSince1970 - re
        guard currentGap >= gap - 1 else {
            Log.info(text: "timerDidUpdate gap < 6 \(currentGap)", tag: "AutoAudioModeChecker")
            return
        }
        Log.info(text: "timerDidUpdate did update", tag: "AutoAudioModeChecker")
        record = nil
        delegate?.autoAudioModeCheckerShouldUpdateMode(recordTime: re)
    }
    
    func timerDidEnd(timer: TimerSource){
        
    }
}
