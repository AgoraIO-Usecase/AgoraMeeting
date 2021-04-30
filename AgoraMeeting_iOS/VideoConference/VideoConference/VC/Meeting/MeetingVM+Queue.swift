//
//  MeetingVM+Thread.swift
//  VideoConference
//
//  Created by ZYP on 2021/4/8.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRte

extension MeetingVM {
    func setSpeakerModeWithInfoOnQueue(info: VideoCell.Info) {
        opQueue.async { [weak self] in
            self?.setSpeakerModeWithInfo(info: info)
        }
    }
    
    func setSpeakerModeWithInfoOnQueue(info: VideoCellMini.Info) {
        opQueue.async { [weak self] in
            self?.setSpeakerModeWithInfo(info: info)
        }
    }
    
    func setVideoModeOnQueue() {
        opQueue.async { [weak self] in
            self?.setVideoMode()
        }
    }
    
    func updateInfoOnQueue(shouldAutoChangeToSpeakerMode: Bool = false) {
        opQueue.async { [weak self] in
            self?.updateInfo(shouldAutoChangeToSpeakerMode: shouldAutoChangeToSpeakerMode)
        }
    }
    
    func handleSceneConntectOnQueue(state: AgoraRteSceneConnectionState, error: AgoraRteError?) {
        opQueue.async { [weak self] in
            self?.handleSceneConntect(state: state, error: error)
        }
    }
}

extension MeetingVM { /** Data + Remote **/
    func addRemoteUserInfoOnQueue(events: [AgoraRteUserEvent], scene: AgoraRteScene) {
        opQueue.async { [weak self] in
            self?.addRemoteUserInfo(events: events, scene: scene)
        }
    }
    
    func removeRemoteUsersInfoOnQueue(events: [AgoraRteUserEvent]) {
        opQueue.async { [weak self] in
            self?.removeRemoteUsersInfo(events: events)
        }
    }
    
    func updateRemoteUserInfoOnQueue(event: AgoraRteUserEvent) {
        opQueue.async { [weak self] in
            self?.updateRemoteUserInfo(event: event)
        }
    }
    
    func updateRemoteUserPropertiesOnQueue(changedProperties: [String], user: AgoraRteUserInfo) {
        opQueue.async { [weak self] in
            self?.updateRemoteUserProperties(changedProperties: changedProperties, user: user)
        }
    }
    
    func addRemoteStreamsOnQueue(events: [AgoraRteMediaStreamEvent]) {
        opQueue.async { [weak self] in
            self?.addRemoteStreams(events: events)
        }
    }
    
    func removeRemoteStreamsOnQueue(events: [AgoraRteMediaStreamEvent]) {
        opQueue.async { [weak self] in
            self?.removeRemoteStreams(events: events)
        }
    }
    
    func updateRemoteStreamsOnQueue(events: [AgoraRteMediaStreamEvent]) {
        opQueue.async { [weak self] in
            self?.updateRemoteStreams(events: events)
        }
    }
}

extension MeetingVM { /** Data + Local **/
    func addLocalUserInfoOnQueue() {
        opQueue.async { [weak self] in
            self?.addLocalUserInfo()
        }
    }
    
    func updateLocalUserInfoOnQueue(event: AgoraRteUserEvent) {
        opQueue.async { [weak self] in
            self?.updateLocalUserInfo(event: event)
        }
    }
    
    func addLocalStreamOnQueue(event: AgoraRteMediaStreamEvent) {
        opQueue.async { [weak self] in
            self?.addLocalStream(event: event)
        }
    }
    
    func updateLocalStreamOnQueue(event: AgoraRteMediaStreamEvent) {
        opQueue.async { [weak self] in
            self?.updateLocalStream(event: event)
        }
    }
    
    func removeLocalStreamOnQueue(event: AgoraRteMediaStreamEvent) {
        opQueue.async { [weak self] in
            self?.removeLocalStream(event: event)
        }
    }
    
    func updateLocalUserPropertiesOnQueue(changedProperties: [String]) {
        opQueue.async { [weak self] in
            self?.updateLocalUserProperties(changedProperties: changedProperties)
        }
    }
}

extension MeetingVM { /** AV **/
    public func subscribeVideoOnQueue(userId: String,
                                      streamId: String,
                                      options: AgoraRteSubscribeOptions) {
        opQueue.async { [weak self] in
            self?.subscribeVideo(userId: userId,
                                 streamId: streamId,
                                 options: options)
        }
    }
    
    public func unsubscribeOnQueue(userId: String, streamId: String) {
        opQueue.async { [weak self] in
            self?.unsubscribe(userId: userId, streamId: streamId)
        }
    }
}

extension MeetingVM { /** WhiteBoard **/
    func handleWhiteBoardShareInfoChangeOnQueue(scene: AgoraRteScene, cause: String?) {
        opQueue.async { [weak self] in
            self?.handleWhiteBoardShareInfoChange(scene: scene, cause: cause)
        }
    }
}

extension MeetingVM { /** Screen Share **/
    func handleScreenInfoChangeOnQueue(scene: AgoraRteScene, cause: String?) {
        opQueue.async { [weak self] in
            self?.handleScreenInfoChange(scene: scene, cause: cause)
        }
    }
}
