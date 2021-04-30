//
//  MeetingVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/4.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import WhiteModule
import Whiteboard
import ReplayKit
import AVKit
import DifferenceKit

class MeetingVC: BaseViewController {
    typealias Info = MeetingVM.Info
    private let meetingView = MeetingView()
    let vm: MeetingVM
    var data: MeetingVM.UpdateInfo = .empty
    weak var memberVC: MemberVC?
    var boardView = WhiteManager.createWhiteBoardView()
    weak var delegate: MeetingVCDelegate?
    var rpPickerView = UIView()
    
    init(loginInfo: LoginVM.Info) {
        self.vm = MeetingVM(loginInfo: loginInfo)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        commonInit()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        meetingView.speakerView.updateScaleVideoViewContentSize()
    }
    
    deinit {
        vm.sendNotiToExtensionForStop()
    }
    
    func setup() {
        meetingView.frame = view.bounds
        meetingView.setMode(.videoFlow, infosCunt: 0, showRightButton: false)
        view.addSubview(meetingView)
        
        meetingView.collectionViewVideo.delegate = self
        meetingView.collectionViewVideo.dataSource = self
        meetingView.collectionViewAudio.delegate = self
        meetingView.collectionViewAudio.dataSource = self
        meetingView.speakerView.delegate = self
        meetingView.videoScrollView.collectionView.delegate = self
        meetingView.videoScrollView.collectionView.dataSource = self
        meetingView.topView.delegate = self
        meetingView.bottomView.delegate = self
        meetingView.messageView.delegate = self
        vm.delegate = self
        
        meetingView.collectionViewVideo.register(WhiteBoardCell.self, forCellWithReuseIdentifier: "WhiteBoardCell")
        meetingView.videoScrollView.collectionView.register(WhiteBoardCell.self, forCellWithReuseIdentifier: "WhiteBoardCell")
        
        let videoNib = UINib(nibName: "VideoCell", bundle: nil)
        meetingView.collectionViewVideo.register(videoNib, forCellWithReuseIdentifier: "VideoCell")
        
        let audioNib = UINib(nibName: "AudioCell", bundle: nil)
        meetingView.collectionViewAudio.register(audioNib, forCellWithReuseIdentifier: "AudioCell")
        
        let videoMiniNib = UINib(nibName: "VideoCellMini", bundle: nil)
        meetingView.videoScrollView.collectionView.register(videoMiniNib, forCellWithReuseIdentifier: "VideoCellMini")
        
        meetingView.topView.title?.text = vm.loginInfo.roomName
        meetingView.topView.startTimer(withCount: vm.getRoomTime())
        if #available(iOS 12.0, *) {
            let rpPickerView = RPSystemBroadcastPickerView()
            rpPickerView.frame = CGRect(x: UIScreen.width/2 - 30, y: UIScreen.height/2 - 30, width: 60, height: 60)
            rpPickerView.showsMicrophoneButton = false
            if let url = Bundle.main.url(forResource: "ScreenSharingBroadcast", withExtension: "appex", subdirectory: "PlugIns") {
                if let bundle = Bundle(url: url) {
                    rpPickerView.preferredExtension = bundle.bundleIdentifier
                }
            }
            view.addSubview(rpPickerView)
            self.rpPickerView = rpPickerView
        }
        
        view.bringSubviewToFront(activityIndicator!)
    }
    
    func commonInit() {
        vm.start()
    }
    
}

extension MeetingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let update = data
        if collectionView == meetingView.videoScrollView.collectionView {
            return update.videoCellMiniInfos.count
        }
        else if collectionView.collectionViewLayout == meetingView.layoutAudio {
            return update.audioCellInfos.count
        }
        else {
            return update.videoCellInfos.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == meetingView.videoScrollView.collectionView { /** 底部列表 **/
            let info = data.videoCellMiniInfos[indexPath.row]
            switch info.type {
            case .video:
                let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: "VideoCellMini", for: indexPath) as! VideoCellMini
                if !info.showHeadImage {
                    vm.renderView(view: cell.videoView,
                                  type: .av,
                                  streamId: info.streamId,
                                  isMe: info.isMe)
                }
                cell.config(info: info)
                return cell
            case .screen:
                let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: "VideoCellMini", for: indexPath) as! VideoCellMini
                if !info.isMe {
                    vm.renderView(view: cell.videoView,
                                  type: .av,
                                  streamId: info.streamId,
                                  isMe: info.isMe)
                }
                cell.config(info: info)
                return cell
            case .board:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhiteBoardCell", for: indexPath) as! WhiteBoardCell
                vm.renderBoardView(view: cell.boardView,
                                   boardId: info.board!.id,
                                   boardToken: info.board!.token,
                                   writable: false)
                return cell
            }
        }
        else {
            if collectionView == meetingView.collectionViewAudio { /** 语音平铺 **/
                Log.info(text: "\(indexPath)", tag: "collectionViewAudio")
                let info = data.audioCellInfos[indexPath.row]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCell", for: indexPath) as! AudioCell
                cell.setImageName(info.headImageName,
                                  name: info.name,
                                  audioEnable: info.audioEnable)
                return cell
            }
            else { /** 视频平铺 **/
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
                let info = data.videoCellInfos[indexPath.row]
                if !info.showHeadImage {
                    vm.renderView(view: cell.videoView,
                                  type: .av,
                                  streamId: info.streamId,
                                  isMe: info.isMe)
                }
                cell.config(info: info)
                cell.delegate = self
                return cell
            }
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == meetingView.videoScrollView.collectionView {
            let info = data.videoCellMiniInfos[indexPath.row]
            vm.setSpeakerModeWithInfoOnQueue(info: info)
            return
        }
        
        if collectionView == meetingView.collectionViewVideo,
           collectionView.collectionViewLayout == meetingView.layoutVideo {
            let info = data.videoCellInfos[indexPath.row]
            vm.setSpeakerModeWithInfoOnQueue(info: info)
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let `cell` = cell as? VideoCell, let info = cell.getInfo {
            vm.subscribeVideoOnQueue(userId: info.userId,
                                     streamId: info.streamId,
                                     options: .hight)
            return
        }
        
        if let `cell` = cell as? VideoCellMini, let info = cell.getInfo {
            vm.subscribeVideoOnQueue(userId: info.userId,
                                     streamId: info.streamId,
                                     options: .low)
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let `cell` = cell as? VideoCell, let info = cell.getInfo {
            vm.unsubscribeOnQueue(userId: info.userId, streamId: info.streamId)
            return
        }
        if let `cell` = cell as? VideoCellMini, let info = cell.getInfo {
            vm.unsubscribeOnQueue(userId: info.userId, streamId: info.streamId)
            return
        }
    }
}

extension MeetingVC: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.meetingView.updatePage()
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.meetingView.updatePage()
        }
    }
}

extension MeetingVC: SpeakerViewDelegate {
    func speakerViewDidTapRightButton(_ action: RightButtonActionType) {
        switch action {
        case .changeMode:
            vm.setVideoModeOnQueue()
            break
        case .whiteBoardEnter:
            vm.emitedBoardVCType()
            break
        case .screenShareQuit:
            showEndScreenAlert()
            break
        @unknown default:
            break
        }
    }
}

extension MeetingVC: MeetingTopViewDelegate, MeetingBottomViewDelegate {
    func meetingBottomView(_ view: MeetingBottomView, didTapButtonWith type: MeetingBottomViewButtonType) {
        switch type {
        case .member:
            showMemberVC()
            break
        case .more:
            vm.makeInfoForShowMoreAlert()
            break
        case .audio:
            let state = view.getAudioState()
            if state == .time { return }
            if state == .redDot { return }
            let enable = state == .inactive
            vm.setAudio(enable: enable)
            break
        case .video:
            let state = view.getVideoState()
            if state == .time { return }
            if state == .redDot { return }
            let enable = state == .inactive
            vm.setVideo(enable: enable)
            break
        case .chat:
            showChatVC()
            break
        default:
            break
        }
    }
    
    public func meetingTopViewDidTapLeaveButton() {
        vm.checkLocalUserHasShare()
    }
    
    func meetingTopViewDidTapCameraButton() {
        vm.switchCamare()
    }
    
    func meetingTopViewDidTapShareButton() {
        copyShareInfo()
    }
}

extension MeetingVC: MeetingVMProtocol {
    
    /** loading or tips */
    func meetingVMShouldShowLoading() {
        showLoading()
    }
    
    func meetingVMShouldDismissLoading() {
        dismissLoading()
    }
    
    func meetingVMDidErrorWithTips(tips: String) {
        dismissLoading()
        showToast(tips)
    }
    
    /** noti */
    
    func meetingVMShouldUpdateNoti(models: [MeetingMessageModel]) {
        meetingView.messageView.update(models)
    }
    
    func meetingVMShouldHidenMessageView(hidden: Bool) {
        meetingView.messageView.isHidden = hidden
    }
    
    func meetingVmShouldShowSelectedNotiVC() {
        showSelectedNotiTypeVC()
    }
    
    func meetingVmShouldShowSystemSettingPage() {
        MeetingVC.showSystemSetting()
    }
    
    /** other */
    
    func meetingVMDidEndWhiteBoard() {
        shouldPopWhiteBoardVC()
    }
    
    func meetingVMShouldChangeBottomViewState(isVideo: Bool, enable: Bool) {
        isVideo ? meetingView.bottomView.setVideEnable(enable) : meetingView.bottomView.setAudioEnable(enable)
    }
    
    func meetingVMShouldShowMoreAlert(info: MeetingVM.MoreAlertShowInfo) {
        showMoreAlert(info: info)
    }
    
    func meetingVMShouldShowEndRoomAlert() {
        showLeaveRoomSheet()
    }
    
    func meetingVMShouldShowEndWhiteBoardAlert() {
        showEndBoardAlert()
    }
    
    func meetingVMShouldShowEndScreenAlert() {
        showEndScreenAlert()
    }
    
    func meetingVMShouldUpdateImRedCount(count: Int) {
        meetingView.bottomView.updateImRedDocCount(count)
    }
    
    func meetingVMShouldAudioRouting(type: MeetingVM.RoutingType) {
        let viewType: MeetingTopViewAudioType = type == .headSet ? .ear : .openSpreak
        meetingView.topView.setAudioRouting(viewType)
    }
    
    func meetingVMDidEndRoom() {
        meetingView.topView.stopTime()
        showRoomEndAlert()
    }
    
    func meetingVMShouldShowRequestMicAlertVC() {
        showRequestMicAlert()
    }
    
    func meetingVMShouldShowRequestCameraAlertVC() {
        showRequestCameraAlert()
    }
    
    func meetingVMShouldUpdateBottomItem(update: MeetingVM.BottomItemUpdateInfo) {
        if update.dataType == .video {
            let state = BottomItemState(rawValue: UInt(update.updateType.rawValue))!
            meetingView.bottomView.updateVideoItem(state, timeCount: update.timeCount)
            return
        }
        
        if update.dataType == .audio {
            let state = BottomItemState(rawValue: UInt(update.updateType.rawValue))!
            meetingView.bottomView.updateAudioItem(state, timeCount: update.timeCount)
            return
        }
    }
    
    func meetingVMShouldShowScreenShareView() {
        handleTapArPickerButton()
    }
    
    func meetingVMShouldShowWhitwBoardVC(info: WhiteBoardVM.Info) {
        let vc = WhiteBoardVC(info: info)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func meetingVMShouldChangeBoardButtonHidden(hidden: Bool) {
        meetingView.speakerView.boardButton.isHidden = hidden
    }
    
    func meetingVMWillLeaveRoom() {
        meetingView.topView.stopTime()
        showScoreView()
    }
    
    func meetingVMDidLeaveRoom() {
        vm.destoryTimer()
        dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.meetingVCDidExitRoom()
        })
    }
    
    func meetingVMLeaveRoomErrorWithTips(tips: String) {
        showToast(tips)
    }
    
    func meetingVMDidUpdateInfos(updateInfo: MeetingVM.UpdateInfo) {
        
        let hasChangeMode = updateInfo.mode != data.mode
        let mode = updateInfo.mode
        switch mode {
        case .videoFlow:
            let count = updateInfo.videoCellInfos.count
            let showRightButton = updateInfo.showRightButton
            meetingView.setMode(mode, infosCunt: count, showRightButton: showRightButton)
            if hasChangeMode {
                data = updateInfo
                meetingView.collectionViewVideo.reloadData()
            }
            else {
                let changeset = StagedChangeset(source: data.videoCellInfos, target: updateInfo.videoCellInfos)
                let old = data.videoCellInfos
                data = updateInfo
                data.videoCellInfos = old
                meetingView.collectionViewVideo.reloadWithOutAnimations(using: changeset) { [weak self](data) in
                    self?.data.videoCellInfos = data
                    self?.meetingView.updatePage()
                }
            }
            break
        case .audioFlow:
            data = updateInfo
            let count = updateInfo.audioCellInfos.count
            let showRightButton = updateInfo.showRightButton
            meetingView.setMode(mode, infosCunt: count, showRightButton: showRightButton)
            meetingView.updatePage()
            break
        case .speaker:
            let count = updateInfo.videoCellMiniInfos.count
            let showRightButton = updateInfo.showRightButton
            let speakerInfo = updateInfo.speakerInfo!
            let selectedInfo = updateInfo.selectedInfo!
            meetingView.setMode(mode, infosCunt: count, showRightButton: showRightButton)
            if hasChangeMode {
                data = updateInfo
                meetingView.videoScrollView.collectionView.reloadData()
            }
            else {
                let changeset = StagedChangeset(source: data.videoCellMiniInfos, target: updateInfo.videoCellMiniInfos)
                let old = data.videoCellMiniInfos
                data = updateInfo
                data.videoCellMiniInfos = old
                meetingView.videoScrollView.collectionView.reloadWithOutAnimations(using: changeset) { [weak self](data) in
                    self?.data.videoCellMiniInfos = data
                }
            }
            meetingVMShouldUpdateSpeakerView(info: selectedInfo, model: speakerInfo)
            break
        default:
            break
        }

        let memberInfos = updateInfo.originalInfos
            .map({ MemberVM.Info(userId: $0.user.userId, uiInfo: $0.toUserCellInfo) })
        memberVC?.updateInfos(infos: memberInfos)
    }
    
    func meetingVMShouldUpdateSpeakerView(info: MeetingVM.Info, model: SpeakerModel) {
        switch info.type {
        case .av:
            let videoView = meetingView.speakerView.getVideoView()
            meetingView.speakerView.setModel(model)
            vm.renderView(view: videoView, info: info)
            vm.subscribeVideo(info: info, options: .hight)
            break
        case .screen:
            meetingView.speakerView.setModel(model)
            if !model.isLocalUser {
                let videoView = meetingView.speakerView.getVideoView()
                vm.renderView(view: videoView, info: info)
                vm.subscribeVideo(info: info, options: .hight)
            }
            break
        case .board:
            meetingView.speakerView.setModel(model)
            let boardView = meetingView.speakerView.getBoardView()
            boardView.isUserInteractionEnabled = false
            vm.renderBoardView(boardView: boardView, info: info, writable: false)
            break
        }
    }
    
    func meetingVMShouldKickout() {
        showKickoutAlert()
    }
}

extension MeetingVC: VideoCellDelegate {
    func videoCell(cell: VideoCell, tapType: VideoCell.SheetAction, info: VideoCell.Info) {
        guard let indexPath = meetingView.collectionViewVideo.indexPath(for: cell) else {
            return
        }
        let dataList = data.videoCellInfos
        guard indexPath.row < dataList.count else {
            return
        }
        let info = dataList[indexPath.row]
        let targetUserId = info.userId
        let isMe = info.isMe

        switch tapType {
        case .setHost, .becomHost:
            vm.setHost(isMe: isMe, targetUserId: targetUserId)
            break
        case .abandonHost:
            vm.abandonHost()
            break
        case .remove:
            vm.removeUser(targetUserId: targetUserId)
            break
        case .closeVideo:
            vm.closeRemoteVideoAudio(isVideo: true, targetUserId: targetUserId)
            break
        case .closeAudio:
            vm.closeRemoteVideoAudio(isVideo: false, targetUserId: targetUserId)
            break
        case .upButton:
            vm.setUpOrDown(targetUserId: targetUserId)
            break
        }
    }
}

extension MeetingVC: MemberVCDelegate {
    func memberVCShouldStartVideoTimer() {
        vm.startRequestVideoTimer()
    }
    
    func memberVCShouldStartAudioTimer() {
        vm.startRequestAudioTimer()
    }
    
    func memberVCDidRequestHostError(error: NSError) {

    }
}

extension MeetingVC: MeetingMessageViewDelegate {
    func messageViewDidTapButton(_ model: MeetingMessageModel) {
        vm.handleNotiButtonTap(model: model)
    }
}

extension MeetingVC: ASCheckBoxAlertVCDelegate {
    
    func checkBoxAlertVCDidTapSureButton(checkBoxSeleted: Bool, style: ASCheckBoxAlertVC.Style) {
        let isVideo = style == .video
        vm.closeAllRemoteVideoAudio(isVideo: isVideo, checkBox: checkBoxSeleted)
    }
    
}

extension MeetingVC: SetVCDelegate, MessageVCDelegate, SelectedNotiTypeVCDelegate {
    func shouldShowSetVC() {
        showSetVC()
    }
    
    func setVcDidUpdateNotiType() {
        vm.addAlawaysCloseNotiIfNeed()
    }
    
    func messageVcDidUpdateNotiType() {
        vm.addAlawaysCloseNotiIfNeed()
    }
    
    func selectedNotiTypeVCdidTapSureButton(type: NotiType) {
        vm.addAlawaysCloseNotiIfNeed()
    }
}



