//
//  Log.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/19.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraLog

class Log {
    
    static let `default` = Log()
    static let folderPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!.appending("/Logs")
    private let logger = AgoraLogger(folderPath: folderPath, filePrefix: "VideoConference", maximumNumberOfFiles: 5)
    
    init() {
        logger.setPrintOnConsoleType(.all)
    }
    
    static func error(error: Error?, tag: String = "") {
        guard let e = error else {
            return
        }
        var text = "<can not get error info>"
        if e.localizedDescription.count > 1 {
            text = e.localizedDescription
        }
        
        let err = e as CustomStringConvertible
        if err.description.count > 1 {
            text = err.description
        }
        
        let str = string(text: text, tag: tag, type: .error)
        Log.default.logger.log(str, type: .error)
    }
    
    static func errorText(text: String, tag: String = "") {
        let str = string(text: text, tag: tag, type: .error)
        Log.default.logger.log(str, type: .error)
    }
    
    static func errorNs(error: NSError?, tag: String = "") {
        guard let e = error else {
            return
        }
        let str = string(text: e.localizedDescription, tag: tag, type: .error)
        Log.default.logger.log(str, type: .error)
    }
    
    static func info(text: String, tag: String = "") {
        let str = string(text: text, tag: tag, type: .info)
        Log.default.logger.log(str, type: .info)
    }
    
    static func warning(text: String, tag: String = "") {
        let str = string(text: text, tag: tag, type: .warning)
        Log.default.logger.log(str, type: .warning)
    }
    
    static func debug(text: String, tag: String = "") {
        let str = string(text: text, tag: tag, type: .debug)
        Log.default.logger.log(str, type: .debug)
    }
    
    static func string(text: String, tag: String, type: AgoraLogType) -> String {
        
        var indicatedString = ""
        switch type {
        case .debug:
            indicatedString = "[VideoConference][Debug]"
            break
        case .info:
            indicatedString = "[VideoConference][Info]"
            break
        case .error:
            indicatedString = "[VideoConference][Error]"
            break
        case .warning:
            indicatedString = "[VideoConference][Warning]"
            break
        default:
            indicatedString = "[VideoConference][Unknow]"
            break
        }
        return indicatedString + "-" + tag +  "---: " + text
    }
}
