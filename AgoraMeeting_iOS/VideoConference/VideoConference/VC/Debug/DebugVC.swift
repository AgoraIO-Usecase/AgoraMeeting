//
//  DebugVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/5.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import AgoraRoom
import SVProgressHUD
import AgoraRte
import ReplayKit

class DebugVC: UITableViewController {
    
    let datdaList = [["创建/加入房间", "离开房间", "更新会议内的房间信息", "更新房间内用户信息",
                      "用户权限更新", "5.3.1.3 踢人", "5.3.2.1 申请成为主持人", "5.2.3.5 发起白板",
                      "5.3.3.6 关闭白板", "5.3.3.3. 发起屏幕分享", "5.3.3.4. 关闭屏幕分享", "5.3.2.2. 请求打开摄像头/麦克风", "5.3.1.2. 全员关闭摄像头/麦克风"],
                     ["通知选择弹框", "成员列表", "消息列表", "白板页面", "屏幕共享", "MemberActionSheet"]]
    let sectionTitles = ["Server Api Test", "UI Test"]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Debug"
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return datdaList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datdaList[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = datdaList[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0, row == 0 {
            testJionAPI()
            return
        }
        
        if section == 0, row == 1 {
            testLeaveAPI()
            return
        }
        
        if section == 0, row == 2 {
            testRoomInfoUpdate()
            return
        }
        
        if section == 0, row == 3 {
            testUserInfoUpdate()
            return
        }
        
        if section == 0, row == 4 {
            testRoomAccess()
        }
        
        if section == 0, row == 5 {
            testKickKickout()
        }
        
        if section == 0, row == 6 {
            testRequest()
        }
        
        if section == 0, row == 7 {
            testRequestBoardStart()
        }
        
        if section == 0, row == 8 {
            testRequestBoardStop()
        }
        
        if section == 0, row == 9 {
            testStartScreenShare()
        }
        
        if section == 0, row == 10 {
            testStopScreenShare()
        }
        
        if section == 0, row == 11 {
            testRequestAVAccess()
        }
        
        if section == 0, row == 12 {
            testRequestPermissionCloseeAll()
        }
        
        if section == 1, row == 0 {
            showNotiTypeSelected()
        }
        
        if section == 1, row == 1 {
            showMemberVC()
        }
        
        if section == 1, row == 2 {
            showMessageVC()
        }
        
        if section == 1, row == 3 {
            showWhiteBoard()
        }
        
        if section == 1, row == 4 {
            showTestScreenShareVC()
        }
        
        if section == 1, row == 5 {
            showMemberSheetVC()
        }
    }

}

extension DebugVC {
    func testJionAPI() {
        let reqParam = HMReqParamsAddRoom()
        reqParam.roomName = "testios1333"
        reqParam.roomId = reqParam.roomName
        reqParam.userName = "zyp"
        reqParam.userId = reqParam.userName
        reqParam.password = ""
        reqParam.cameraAccess = false
        reqParam.micAccess = false
        reqParam.duration = 10000
        reqParam.totalPeople = 1000
        SVProgressHUD.show()
        HttpManager.request(reqParam) { (respParam) in
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    func testLeaveAPI() {
        SVProgressHUD.show()
        
        HttpManager.requestLeaveRoom(withRoomId: "testios1", userId: "zyp") {
            SVProgressHUD.showSuccess(withStatus: "成功")
        } faulure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }

    }
    
    // 更新会议内的房间信息
    func testRoomInfoUpdate() {
        let reqParams = HMReqParamsRoomInfoUpdate()
        reqParams.roomName = "testios2"
        reqParams.roomId = "testios2"
        reqParams.password = "12345"
        reqParams.userId = "zyp"
        SVProgressHUD.show()
        HttpManager.requestRoomInfoUpdate(withParam: reqParams) {
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    /// 更新房间内用户信息
    func testUserInfoUpdate() {
        let reqParams = HMReqParamsUserInfoUpdate()
        reqParams.roomId = "testios2"
        reqParams.userName = "zyp"
        reqParams.userId = "zyp"
        
        SVProgressHUD.show()
        HttpManager.requestUserInfo(withParam: reqParams) {
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    
    /// 用户权限更新
    func testRoomAccess() {
        let reqParams = HMReqParamsUserPermissionsAll()
        reqParams.roomId = "testios2"
        reqParams.userId = "zyp"
        reqParams.cameraAccess = true
        reqParams.micAccess = true
        
        SVProgressHUD.show()
        HttpManager.requestUserPermissionsUpdate(reqParams) {
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    /// 5.3.1.3 踢人
    func testKickKickout() {
        let reqParams = HMReqParamsKickout()
        reqParams.roomId = "testios2"
        reqParams.userId = "zyp"
        reqParams.targetUserId = "zypq"
        
        SVProgressHUD.show()
        HttpManager.request(reqParams) {
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    /// 5.3.2.1 申请成为主持人
    func testRequest() {
        let req = HMReqParamsHostAbondon()
        req.roomId = "testios2"
        req.userId = "zyp"
        
        SVProgressHUD.show()
        HttpManager.requestHostApply(withParam: req) {
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    /// 5.2.3.5 发起白板
    func testRequestBoardStart() {
        let param = HMReqParamsHostAbondon()
        param.roomId = "testios2"
        param.userId = "zyp"
        SVProgressHUD.show()
        HttpManager.requestWhiteBoardStart(withParam: param) {
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }

    }
    
    /// 5.3.3.6 关闭白板
    func testRequestBoardStop() {
        let param = HMReqParamsHostAbondon()
        param.userId = "0878dafe2374adc39fe3ed25059a31de"
        param.roomId = "0f8c6708451d22fa5b0276099e2fabdc"
        SVProgressHUD.show()
        HttpManager.requestWhiteBoardStop(withParam: param) {
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    /// 5.3.3.3. 发起屏幕分享
    func testStartScreenShare() {
        let param = HMReqParamsHostAbondon()
        param.roomId = "0f8c6708451d22fa5b0276099e2fabdc"
        param.userId = "0878dafe2374adc39fe3ed25059a31de"
        SVProgressHUD.show()
        HttpManager.requestScreenShareStart(withParam: param) { (token) in
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }

    }
    
    /// 5.3.3.4. 关闭屏幕分享
    func testStopScreenShare() {
        let param = HMReqScreenShareStop()
        param.roomId = "0f8c6708451d22fa5b0276099e2fabdc"
        param.userId = "0878dafe2374adc39fe3ed25059a31de"
        param.streamId = ""
        SVProgressHUD.show()
        HttpManager.requestScreenShareStop(withParam: param) {
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }

    }
    
    /// 5.3.2.2. 请求打开摄像头/麦克风
    func testRequestAVAccess() {
        let param = HMReqParamsUserPermissionsAll()
        param.roomId = "0f8c6708451d22fa5b0276099e2fabdc"
        param.userId = "0878dafe2374adc39fe3ed25059a31de"
        param.micAccess = true
        param.cameraAccess = false
        SVProgressHUD.show()
        HttpManager.requestPermissionApply(withParam: param) { (resp) in
            SVProgressHUD.showSuccess(withStatus: "成功")
        } failure: { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    /// 全员关闭摄像头麦克风
    func testRequestPermissionCloseeAll() {
        let param = HMReqParamsUserPermissionsAll()
        param.roomId = "de5d3e120ee84dc2ee34b548186446c5"
        param.userId = "3bad6af0fa4b8b330d162e19938ee981"
        param.micAccess = true
        param.cameraAccess = false
        SVProgressHUD.show()
//        
//        HttpManager.requestUserPermissionsClose(param) {
//            SVProgressHUD.showSuccess(withStatus: "成功")
//        } failure: { (error) in
//            SVProgressHUD.showError(withStatus: error.localizedDescription)
//        }
    }
    
    func showMemberSheetVC() {
        let vc = MemberSheetVC()
        var actions = [MemberSheetVC.Action]()
        let a1 = MemberSheetVC.Action(title: "111", style: .default, handler: {
            print("111")
        })
        let a2 = MemberSheetVC.Action(title: "222", style: .default, handler: {
            print("222")
        })
        let a3 = MemberSheetVC.Action(title: "333", style: .default, handler: {
            print("333")
        })
        let a4 = MemberSheetVC.Action(title: "444", style: .default, handler: {
            print("444")
        })
        actions += [a1, a2, a3, a4]
        let cancle = MemberSheetVC.Action(title: "取消", style: .cancel, handler: nil)
        actions.append(cancle)
//        vc.set(actions: actions)
        vc.set(title: "1231321", image: UIImage(named: "avatar_0")!)
        vc.show(in: self)
    }
    
}

extension DebugVC {
    
    func showNotiTypeSelected() {
        let vc = SelectedNotiTypeVC()
        vc.show(in: self, selected: NotiType(rawValue: ARUserDefaults.getNotiTypeValue())!)
    }
    
    func showMemberVC() {
        let infos = [MemberVM.Info]()
        let vc = MemberVC(infos: infos)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showMessageVC() {
        let vc = MessageVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showWhiteBoard() {
//        let vc = WhiteBoardVC(role: .owner)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showTestScreenShareVC() {
        if #available(iOS 12.0, *) {
            let vc = TestScreenShareVC()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    
}
