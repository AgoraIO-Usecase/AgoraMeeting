//
//  WhiteBoardVM.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/3.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRoom
import WhiteModule

protocol WhiteBoardVMDelegate: NSObject {
    func whiteBoardVMDidUpdateInfo(info: WhiteBoardVM.Info)
    func whiteBoardVMShouldShowLoading()
    func whiteBoardVMShouldDismissLoading()
    func whiteBoardVMDidErrorWithTips(tips: String)
    func whiteBoardVMDidCloseBoard()
}

class WhiteBoardVM: NSObject {
    weak var delegate: WhiteBoardVMDelegate?
    var info: Info!
    let whiteManager = WhiteManager()
    
    init(info: Info) {
        self.info = info
    }
    
    func start(whiteBoardView: UIView) {
        whiteManager.initWhiteSDK(whiteBoardView, dataSourceDelegate: self)
        whiteManager.joinWhiteRoom(withBoardId: info.boardId, boardToken: info.boardToken, whiteWriteModel: info.role != .audience) {
            Log.info(text: "WhiteBoardVC joinWhiteRoom success")
        } completeFail: { (error) in
            if let e = error {
                Log.errorText(text: e.localizedDescription)
            }
        }
        delegate?.whiteBoardVMDidUpdateInfo(info: info)
    }
    
    
    
    func closeWhiteBoard() {
        let param = HMReqParamsHostAbondon()
        param.roomId = info.roomId
        param.userId = ARConferenceManager.getLocalUser().info.userId
        delegate?.whiteBoardVMShouldShowLoading()
        HttpManager.requestWhiteBoardStop(withParam: param) {
            self.delegate?.whiteBoardVMShouldDismissLoading()
            self.delegate?.whiteBoardVMDidCloseBoard()
        } failure: { (error) in
            self.delegate?.whiteBoardVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func requestInteract() {
        let param = HMReqParamsHostAbondon()
        param.roomId = info.roomId
        param.userId = ARConferenceManager.getLocalUser().info.userId
        delegate?.whiteBoardVMShouldShowLoading()
        HttpManager.requestWhiteBoardInteract(withParam: param) {
            self.delegate?.whiteBoardVMShouldDismissLoading()
            self.info.updateRole(role: .interactor)
            self.setWritableIfNeed()
            self.delegate?.whiteBoardVMDidUpdateInfo(info: self.info)
        } failure: { (error) in
            self.delegate?.whiteBoardVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func abandonInteract() {
        let param = HMReqParamsHostAbondon()
        param.roomId = info.roomId
        param.userId = ARConferenceManager.getLocalUser().info.userId
        delegate?.whiteBoardVMShouldShowLoading()
        HttpManager.requestWhiteBoardLeave(withParam: param) {
            self.delegate?.whiteBoardVMShouldDismissLoading()
            self.info.updateRole(role: .audience)
            self.setWritableIfNeed()
            self.delegate?.whiteBoardVMDidUpdateInfo(info: self.info)
        } failure: { (error) in
            self.delegate?.whiteBoardVMDidErrorWithTips(tips: error.localizedDescription)
        }
    }
    
    func setStrokeColor(color: [NSNumber]) {
        whiteManager.setWhiteStrokeColor(color)
    }

    
    func setApplianceAction(action: Action) {
        whiteManager.setWhiteApplianceName(action.rawValue)
    }
    
    func setWritableIfNeed() {
        let writable = info.role != .audience
        whiteManager.setWritable(writable) { (success, errror) in
            if success { Log.info(text: "白板可写设置成功\(writable)") }
            else { Log.error(error: errror) }
        }
    }
    
    
}

extension WhiteBoardVM: WhiteManagerDelegate {
    
}

extension WhiteBoardVM {
    struct Info {
        let boardId: String
        let boardToken: String
        var role: Role
        let roomId: String
        let userId: String
        
        mutating func updateRole(role: Role) {
            self.role = role
        }
        
        enum Role {
            /// 白板拥有者 WhiteBoard Owner
            case owner
            /// 白板观众者 WhiteBoard Audience
            case audience
            /// 白板互动者 WhiteBoard interactor
            case interactor
        }
    }
    
    enum Action: String {
        case select = "selector"
        case pan = "pencil"
        case text = "text"
        case eraser = "eraser"
        case rectangle = "rectangle"
        case ellipse = "ellipse"
    }
}
