//
//  TimerSource.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/31.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

protocol TimerSourceDelegate: NSObject {
    func timerDidUpdate(timer: TimerSource, current count: Int)
    func timerDidEnd(timer: TimerSource)
}

class TimerSource: NSObject {
    private var timer: Timer?
    private var count = 0
    var shouldEndSatrtWhenCountZero = true
    var isStarting = false
    weak var delegate: TimerSourceDelegate?
    var tag = 0
    let printTag = 1
    
    deinit {
        if tag == printTag { print("===deinit for print tag") }
        else { print("=== TimerSourcedeinit ") }
        makeTimerEnd()
    }
    
    func reStart(duratedCount: Int) {
        start(duratedCount: duratedCount)
    }
    
    /// max count (as fo second) for time
    func start(duratedCount: Int) {
        if tag == printTag {
            Log.debug(text: "===start:\(duratedCount)")
        }
        count = duratedCount
        isStarting = true
        if timer != nil {

            return
        }
        timer = Timer(timeInterval: 1, target: self, selector: #selector(timeout), userInfo: nil, repeats: true)
        timer?.fire()
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stop() {
        if tag == printTag { Log.debug(text: "===stop:\(count)") }
        isStarting = false
        delegate?.timerDidEnd(timer: self)
    }
    
    func invalied() {
        if tag == printTag { Log.debug(text: "===invalied") }
        makeTimerEnd()
    }
    
    private func makeTimerEnd() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timeout() {
        if tag == printTag {
            Log.debug(text: "====count:\(count)")
        }
        guard isStarting else {
            return
        }
        if count == 0 {
            delegate?.timerDidEnd(timer: self)
            if shouldEndSatrtWhenCountZero {
                isStarting = false
            }
            return
        }
        
        count -= 1
        delegate?.timerDidUpdate(timer: self, current: count)
    }
}
