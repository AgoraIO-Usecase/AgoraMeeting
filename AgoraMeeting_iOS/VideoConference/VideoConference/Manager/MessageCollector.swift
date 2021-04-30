//
//  MessageCollector.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/25.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte

protocol MessageObserver: NSObject {
    func update(newValue: [MessageCollector.Info])
    func updateUnReadCount(count: Int)
}

class MessageCollector {
    
    weak var delegate1: MessageObserver?
    weak var delegate2: MessageObserver?
    
    static let `default` = MessageCollector()
    private var messages = [Info]()
    private var unReadCount = 0
    
    func clean() {
        messages = [Info]()
    }
    
    func addUnReadCount() {
        unReadCount += 1
        updateOnMainThread(count: unReadCount)
    }
    
    func cleanUnReadCount() {
        unReadCount = 0
        updateOnMainThread(count: unReadCount)
    }
    
    func add(message: Info) {
        messages.append(message)
        updateOnMainThread(messages: messages)
    }
    
    func update(message: Info, newTimeStmp: TimeInterval? = nil) {
        for i in 0..<messages.count {
            if messages[i] == message {
                var info = message
                if let newTimeStmp = newTimeStmp {
                    info.setTimeStamp(stamp: newTimeStmp)
                }
                messages[i] = info
                break
            }
        }
        updateOnMainThread(messages: messages)
    }
    
    private func updateOnMainThread(messages: [Info]) {
        if Thread.isMainThread {
            delegate1?.update(newValue: messages)
            delegate2?.update(newValue: messages)
            return
        }
        DispatchQueue.main.sync {
            delegate1?.update(newValue: messages)
            delegate2?.update(newValue: messages)
        }
    }
    
    private func updateOnMainThread(count: Int) {
        if Thread.isMainThread {
            delegate1?.updateUnReadCount(count: unReadCount)
            delegate2?.updateUnReadCount(count: unReadCount)
            return
        }
        DispatchQueue.main.sync {
            delegate1?.updateUnReadCount(count: unReadCount)
            delegate2?.updateUnReadCount(count: unReadCount)
        }
    }
    
    func getAll() -> [Info] {
        return messages
    }
    
    struct Info: Equatable {
        let userId: String
        let userName: String
        let message: String
        var timestamp: TimeInterval
        let isSelfSend: Bool
        let type: MessageType
        var status: MessageCollector.Info.Status
        var showTime = true
        
        enum MessageType: Int {
            case chat = 1
            case userOnline = 2
            case roomInfo = 3
            case userInfo = 4
            case replay = 5
            case shareScreen = 6
        }
        
        mutating func setStatus(status: Status) {
            self.status = status
        }
        
        mutating func setTimeStamp(stamp: TimeInterval) {
            self.timestamp = stamp
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.userId == rhs.userId && lhs.timestamp == rhs.timestamp
        }
        
        enum Status: UInt {
            case sending
            case success
            case fail
            case recv
        }
    }
    
    
    
}


