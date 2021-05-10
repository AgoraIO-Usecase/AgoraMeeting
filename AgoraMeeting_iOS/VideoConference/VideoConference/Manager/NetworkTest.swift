//
//  NetworkTest.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/9.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte

protocol NetworkTestDelegate: NSObject {
    func networkTestDidUpdateQuality(networkTest: NetworkTest, quality: AgoraRteNetworkQuality)
}

class NetworkTest: NSObject {
    let appId: String
    let netService: AgoraRteNetworkTestService
    let timeInterval: TimeInterval
    var isStarting = false
    var delegate: NetworkTestDelegate?
    
    init(appId: String, timeInterval: TimeInterval = 5) {
        self.appId = appId
        self.timeInterval = timeInterval
        self.netService = AgoraRteNetworkTestService(appId: appId)
        super.init()
        commonInit()
    }
    
    private func commonInit() {
        netService.delegate = self
    }
    
    public func start() {
        if isStarting { return }
        isStarting = true
        netService.startLastmileProbeTest(nil)
    }
    
    public func stop() {
        isStarting = false
        netService.stopLastmileProbeTest()
    }
    
}

extension NetworkTest: AgoraRteNetworkTestDelegate {
    
    func networkTestService(_ service: AgoraRteNetworkTestService, lastmileQuality quality: AgoraRteNetworkQuality) {
        Log.debug(text: "lastmileQuality quality", tag: "networkTestService")
        delegate?.networkTestDidUpdateQuality(networkTest: self, quality: quality)
        service.stopLastmileProbeTest()
        if isStarting {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                if !self.isStarting { return }
                service.startLastmileProbeTest(nil)
            }
        }
    }
    
}
