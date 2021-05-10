//
//  MeetingVMProtocol.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/9.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

protocol MeetingVMProtocol: NSObject {
    func meetingVMShouldShowLoading()
    func meetingVMShouldDismissLoading()
    func meetingVMDidErrorWithTips(tips: String)
    
    func meetingVMWillLeaveRoom()
    func meetingVMDidLeaveRoom()
    func meetingVMLeaveRoomErrorWithTips(tips: String)
    func meetingVMDidUpdateInfos(updateInfo: MeetingVM.UpdateInfo)
    func meetingVMShouldUpdateSpeakerView(info: MeetingVM.Info, model: SpeakerModel)
    func meetingVMShouldChangeBoardButtonHidden(hidden: Bool)
    func meetingVMShouldShowWhitwBoardVC(info: WhiteBoardVM.Info)
    func meetingVMShouldShowScreenShareView()
    func meetingVMShouldUpdateBottomItem(update: MeetingVM.BottomItemUpdateInfo)
    func meetingVMShouldShowRequestMicAlertVC()
    func meetingVMShouldShowRequestCameraAlertVC()
    func meetingVMShouldKickout()
    func meetingVMShouldAudioRouting(type: MeetingVM.RoutingType)
    /// room tiem end
    func meetingVMDidEndRoom()
    
    /// noti
    func meetingVMShouldUpdateNoti(models: [MeetingMessageModel])
    func meetingVmShouldShowSystemSettingPage()
    func meetingVmShouldShowSelectedNotiVC()
    func meetingVMShouldHidenMessageView(hidden: Bool)
    /// ImRedCount
    func meetingVMShouldUpdateImRedCount(count: Int)
    
    /// should end while exit room
    func meetingVMShouldShowEndScreenAlert()
    func meetingVMShouldShowEndWhiteBoardAlert()
    func meetingVMShouldShowEndRoomAlert()
    
    func meetingVMShouldShowMoreAlert(info: MeetingVM.MoreAlertShowInfo)
    
    func meetingVMShouldChangeBottomViewState(isVideo: Bool, enable: Bool)
    func meetingVMDidEndWhiteBoard()
}

