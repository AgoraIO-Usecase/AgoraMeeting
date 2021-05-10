//
//  NotiTimerSource.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/23.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

protocol NotiTimerSourceDelegate: NSObject {
    func notiTimerSourceDidCome()
}

class NotiTimerSource {
    var timer: Timer?
    var isStarting = false
    weak var delegate: NotiTimerSourceDelegate?
    
    func start() {
        guard isStarting == false else {
            return
        }
        timer?.invalidate()
        timer = nil
        isStarting = true
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timeout),
                                     userInfo: nil,
                                     repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stop() {
        makeTimerEnd()
        isStarting = false
    }
    
    private func makeTimerEnd() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timeout() {
        delegate?.notiTimerSourceDidCome()
    }
    
}
