//
//  MeetingVM+Delegate+MainQueue.swift
//  VideoConference
//
//  Created by ZYP on 2021/4/8.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation


extension MeetingVM {
    func invokeMeetingVMShouldShowLoading(){
        if Thread.isMainThread {
            delegate?.meetingVMShouldShowLoading()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldShowLoading()
        }
    }
    
    func invokeMeetingVMShouldDismissLoading() {
        if Thread.isMainThread {
            delegate?.meetingVMShouldDismissLoading()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldDismissLoading()
        }
    }
    
    func invokeMeetingVMDidErrorWithTips(tips: String) {
        if Thread.isMainThread {
            delegate?.meetingVMDidErrorWithTips(tips: tips)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMDidErrorWithTips(tips: tips)
        }
    }
    
    func invokeMeetingVMWillLeaveRoom() {
        if Thread.isMainThread {
            delegate?.meetingVMWillLeaveRoom()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMWillLeaveRoom()
        }
    }
    func invokeMeetingVMDidLeaveRoom() {
        if Thread.isMainThread {
            delegate?.meetingVMDidLeaveRoom()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMDidLeaveRoom()
        }
    }
    func invokeMeetingVMLeaveRoomErrorWithTips(tips: String) {
        if Thread.isMainThread {
            delegate?.meetingVMLeaveRoomErrorWithTips(tips: tips)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMLeaveRoomErrorWithTips(tips: tips)
        }
    }
    func invokeMeetingVMDidUpdateInfos(updateInfo: UpdateInfo) {
        if Thread.isMainThread {
            delegate?.meetingVMDidUpdateInfos(updateInfo: updateInfo)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMDidUpdateInfos(updateInfo: updateInfo)
        }
    }
    func invokeMeetingVMShouldUpdateSpeakerView(info: MeetingVM.Info, model: SpeakerModel) {
        if Thread.isMainThread {
            delegate?.meetingVMShouldUpdateSpeakerView(info: info, model: model)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldUpdateSpeakerView(info: info, model: model)
        }
    }
    func invokeMeetingVMShouldChangeBoardButtonHidden(hidden: Bool) {
        if Thread.isMainThread {
            delegate?.meetingVMShouldChangeBoardButtonHidden(hidden: hidden)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldChangeBoardButtonHidden(hidden: hidden)
        }
    }
    func invokeMeetingVMShouldShowWhitwBoardVC(info: WhiteBoardVM.Info) {
        if Thread.isMainThread {
            delegate?.meetingVMShouldShowWhitwBoardVC(info: info)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldShowWhitwBoardVC(info: info)
        }
    }
    func invokeMeetingVMShouldShowScreenShareView() {
        if Thread.isMainThread {
            delegate?.meetingVMShouldShowScreenShareView()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldShowScreenShareView()
        }
    }
    func invokeMeetingVMShouldUpdateBottomItem(update: MeetingVM.BottomItemUpdateInfo) {
        if Thread.isMainThread {
            delegate?.meetingVMShouldUpdateBottomItem(update: update)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldUpdateBottomItem(update: update)
        }
    }
    func invokeMeetingVMShouldShowRequestMicAlertVC() {
        if Thread.isMainThread {
            delegate?.meetingVMShouldShowRequestMicAlertVC()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldShowRequestMicAlertVC()
        }
    }
    func invokeMeetingVMShouldShowRequestCameraAlertVC() {
        if Thread.isMainThread {
            delegate?.meetingVMShouldShowRequestCameraAlertVC()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldShowRequestCameraAlertVC()
        }
    }
    func invokeMeetingVMShouldKickout() {
        if Thread.isMainThread {
            delegate?.meetingVMShouldKickout()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldKickout()
        }
    }
    func invokeMeetingVMShouldAudioRouting(type: MeetingVM.RoutingType) {
        if Thread.isMainThread {
            delegate?.meetingVMShouldAudioRouting(type: type)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldAudioRouting(type: type)
        }
    }
    /// room tiem end
    func invokeMeetingVMDidEndRoom() {
        if Thread.isMainThread {
            delegate?.meetingVMDidEndRoom()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMDidEndRoom()
        }
    }
    
    /// noti
    func invokeMeetingVMShouldUpdateNoti(models: [MeetingMessageModel]) {
        if Thread.isMainThread {
            delegate?.meetingVMShouldUpdateNoti(models: models)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldUpdateNoti(models: models)
        }
    }
    func invokeMeetingVmShouldShowSystemSettingPage() {
        if Thread.isMainThread {
            delegate?.meetingVmShouldShowSystemSettingPage()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVmShouldShowSystemSettingPage()
        }
    }
    func invokeMeetingVmShouldShowSelectedNotiVC() {
        if Thread.isMainThread {
            delegate?.meetingVmShouldShowSelectedNotiVC()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVmShouldShowSelectedNotiVC()
        }
    }
    func invokeMeetingVMShouldHidenMessageView(hidden: Bool) {
        if Thread.isMainThread {
            delegate?.meetingVMShouldHidenMessageView(hidden: hidden)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldHidenMessageView(hidden: hidden)
        }
    }
    /// ImRedCount
    func invokeMeetingVmShouldUpdateImRedCount(count: Int) {
        if Thread.isMainThread {
            delegate?.meetingVMShouldUpdateImRedCount(count: count)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldUpdateImRedCount(count: count)
        }
    }
    
    /// should end while exit room
    func invokeMeetingVMShouldShowEndScreenAlert() {
        if Thread.isMainThread {
            delegate?.meetingVMShouldShowEndScreenAlert()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldShowEndScreenAlert()
        }
    }
    func invokeMeetingVMShouldShowEndWhiteBoardAlert() {
        if Thread.isMainThread {
            delegate?.meetingVMShouldShowEndWhiteBoardAlert()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldShowEndWhiteBoardAlert()
        }
    }
    func invokeMeetingVMShouldShowEndRoomAlert() {
        if Thread.isMainThread {
            delegate?.meetingVMShouldShowEndRoomAlert()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldShowEndRoomAlert()
        }
    }
    
    func invokeMeetingVMShouldShowMoreAlert(info: MeetingVM.MoreAlertShowInfo) {
        if Thread.isMainThread {
            delegate?.meetingVMShouldShowMoreAlert(info: info)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldShowMoreAlert(info: info)
        }
    }
    
    func invokeMeetingVMShouldChangeBottomViewState(isVideo: Bool, enable: Bool) {
        if Thread.isMainThread {
            delegate?.meetingVMShouldChangeBottomViewState(isVideo: isVideo, enable: enable)
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMShouldChangeBottomViewState(isVideo: isVideo, enable: enable)
        }
    }
    
    func invokeMeetingVMDidEndWhiteBoard() {
        if Thread.isMainThread {
            delegate?.meetingVMDidEndWhiteBoard()
            return
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.delegate?.meetingVMDidEndWhiteBoard()
        }
    }
}
