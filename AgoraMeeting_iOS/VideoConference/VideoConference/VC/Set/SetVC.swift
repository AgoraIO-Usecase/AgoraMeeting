//
//  SetVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/15.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import AgoraRoom

protocol SetVCDelegate: NSObject {
    func setVcDidUpdateNotiType()
}

class SetVC: BaseViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)
    var notiType = NotiType(rawValue: ARUserDefaults.getNotiTypeValue())!
    var uploading = false
    weak var delegate: SetVCDelegate?
    var info: Info!
    
    init(info: Info) {
        self.info = info
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setup() {
        title = NSLocalizedString("set_t17", comment: "")
        view.backgroundColor = .white
        tableView.frame = view.bounds
        
        let setImageCellNib = UINib(nibName: SetImageCell.idf(), bundle: nil)
        let setTextCellNib = UINib(nibName: SetTextFieldCell.idf(), bundle: nil)
        let setSwitchCellNib = UINib(nibName: SetSwitchCell.idf(), bundle: nil)
        let setCenterTextCellNib = UINib(nibName: SetCenterTextCell.idf(), bundle: nil)
        let setLabelCellNib = UINib(nibName: SetLabelCell.idf(), bundle: nil)
        
        tableView.register(setImageCellNib, forCellReuseIdentifier: SetImageCell.idf())
        tableView.register(setTextCellNib, forCellReuseIdentifier: SetTextFieldCell.idf())
        tableView.register(setSwitchCellNib, forCellReuseIdentifier: SetSwitchCell.idf())
        tableView.register(setCenterTextCellNib, forCellReuseIdentifier: SetCenterTextCell.idf())
        tableView.register(setLabelCellNib, forCellReuseIdentifier: SetLabelCell.idf())
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        view.bringSubviewToFront(activityIndicator!)
    }

}

extension SetVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 2 }
        if section == 1 { return 3 }
        if section == 2 { return 2 }
        if section == 3 { return 4 }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let textColor = UIColor(red: 0.254675, green: 0.302331, blue: 0.349586, alpha: 1)
        if section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            }
            cell?.textLabel?.numberOfLines = 0
            cell!.textLabel?.textColor = UIColor.text()
            cell?.detailTextLabel?.numberOfLines = 0
            cell?.textLabel?.text = row == 0 ? NSLocalizedString("set_t11", comment: "") : NSLocalizedString("set_t8", comment: "")
            cell?.detailTextLabel?.text = row == 0 ? info.roomName : info.roomPsd
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
            return cell!
        }
        
        if section == 1 {
            if row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SetImageCell.idf(), for: indexPath) as! SetImageCell
                cell.tipText?.text = NSLocalizedString("set_t19", comment: "")
                cell.imgView?.image = UIImage(named: info.headImageName)
                cell.selectionStyle = .none
                return cell
            }
            else if row == 1 {
                var cell  = tableView.dequeueReusableCell(withIdentifier: "cell")
                if cell == nil {
                    cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                }
                cell!.textLabel?.text = NSLocalizedString("set_t13", comment: "")
                cell!.textLabel?.textColor = UIColor.text()
                cell?.accessoryType = .none
                cell!.detailTextLabel?.text = info.userName
                return cell!
            }
            else {
                var cell  = tableView.dequeueReusableCell(withIdentifier: "cell")
                if cell == nil {
                    cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                }
                cell!.textLabel?.text = NSLocalizedString("set_t16", comment: "")
                cell!.textLabel?.textColor = UIColor.text()
                cell!.detailTextLabel?.text = info.roleName
                cell?.selectionStyle = .none
                return cell!
            }
        }
        
        if section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SetSwitchCell.idf(), for: indexPath) as! SetSwitchCell
            cell.textLabel?.textColor = UIColor.text()
            cell.switchBtn?.isEnabled = true
            if row == 0 {
                cell.tipText?.text = NSLocalizedString("set_t9", comment: "")
                cell.switchBtn?.isOn = info.openVideoShoudApprove
                cell.switchBtn?.isEnabled = info.userRole == "host"
                cell.selectionStyle = .none
                cell.indexPath = indexPath
                cell.delegate = self
                return cell
            }
            else {
                cell.tipText?.text = NSLocalizedString("set_t10", comment: "")
                cell.switchBtn?.isOn = info.openAudioShoudApprove
                cell.switchBtn?.isEnabled = info.userRole == "host"
                cell.selectionStyle = .none
                cell.indexPath = indexPath
                cell.delegate = self
                return cell
            }
        }
        
        if section == 3 {
            if row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SetSwitchCell.idf(), for: indexPath) as! SetSwitchCell
                cell.textLabel?.textColor = UIColor.text()
                cell.tipText?.text = NSLocalizedString("set_t20", comment: "")
                cell.switchBtn?.isOn = false
                cell.switchBtn?.isEnabled = false
                cell.selectionStyle = .none
                return cell
            }
            else if row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SetSwitchCell.idf(), for: indexPath) as! SetSwitchCell
                cell.textLabel?.textColor = UIColor.text()
                cell.tipText?.text = NSLocalizedString("set_t23", comment: "")
                cell.switchBtn?.isOn = false
                cell.switchBtn?.isEnabled = false
                cell.selectionStyle = .none
                return cell
            }
            else if row == 2 {
                var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
                if cell == nil {
                    cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                }
                cell!.textLabel?.text = NSLocalizedString("set_t5", comment: "")
                cell!.textLabel?.textColor = UIColor.text()
                cell!.detailTextLabel?.text = notiType.description
                cell!.accessoryType = .none
                cell!.detailTextLabel?.textColor = UIColor(hex: 0x268CFF)
                return cell!
            }
            else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
                if cell == nil {
                    cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                }
                cell!.textLabel?.textColor = textColor
                cell!.textLabel?.text = NSLocalizedString("set_t4", comment: "")
                cell!.accessoryType = .disclosureIndicator
                return cell!
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SetCenterTextCell.idf(), for: indexPath) as! SetCenterTextCell
        cell.tipText?.text = NSLocalizedString("set_t2", comment: "")
        cell.tipText?.textColor = UIColor(hex: 0x323C47)
        cell.selectionStyle = uploading ? .none : .gray
        cell.setLoadingState(uploading)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0, indexPath.row == 1 {
            
            return
        }
        
        if indexPath.section == 1, indexPath.row == 1 {

            return
        }
        
        if indexPath.section == 3, indexPath.row == 2 {
            showSelectedNotiTypeVC()
        }
        
        if indexPath.section == 4 {
            uploadLog()
        }
        
        if indexPath.section == 3, indexPath.row == 3 {
            showAboutVC()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 { return NSLocalizedString("set_t24", comment: "") }
        return nil
    }
    
    func showEditVC(type: EditVCType) {
        
    }
    
    func update(type: EditVCType, text: String) {
        if let tips = type == .psd ? text.inValidPsdText : text.inValidUserNameText {
            showToast(tips)
            return
        }
        type == .psd ? updatePsd(text: text) : updateUserName(text: text)
    }
    
    func updatePsd(text: String) {
        let reqParams = HMReqParamsRoomInfoUpdate()
        reqParams.password = text
        reqParams.roomId = info.roomId
        reqParams.roomName = info.roomName
        reqParams.userId = info.userId
        showLoading()
        HttpManager.requestRoomInfoUpdate(withParam: reqParams) {
            self.dismissLoading()
            self.info.roomPsd = text
            self.tableView.reloadData()
        } failure: { (error) in
            self.dismissLoading()
            self.showToast(error.localizedDescription)
        }
    }
    
    func updateUserName(text: String) {
        let reqParams = HMReqParamsUserInfoUpdate()
        reqParams.roomId = info.roomId
        reqParams.userName = text
        reqParams.userId = info.userId
        showLoading()
        HttpManager.requestUserInfo(withParam: reqParams) {
            self.dismissLoading()
            self.info.userName = text
            self.tableView.reloadData()
        } failure: { (error) in
            self.dismissLoading()
            self.showToast(error.localizedDescription)
        }
    }
    
    func showSelectedNotiTypeVC() {
        let vc = SelectedNotiTypeVC()
        vc.delegate = self
        vc.show(in: self, selected: NotiType(rawValue: ARUserDefaults.getNotiTypeValue())!)
    }
    
    func setVideoAccess() {
        showLoading()
        let reqParams = HMReqParamsUserPermissionsAll()
        reqParams.cameraAccess = info.openVideoShoudApprove
        reqParams.micAccess = !info.openAudioShoudApprove
        reqParams.roomId = info.roomId
        reqParams.userId = info.userId
        HttpManager.requestUserPermissionsUpdate(reqParams) {
            self.dismissLoading()
            self.info.openVideoShoudApprove = !self.info.openVideoShoudApprove
            ARConferenceManager.getEntryParams().videoAccess = reqParams.cameraAccess
        } failure: { (error) in
            self.dismissLoading()
            self.showToast(error.localizedDescription)
            self.tableView.reloadData()
        }
    }
    
    func setAudioAccess() {
        showLoading()
        let reqParams = HMReqParamsUserPermissionsAll()
        reqParams.cameraAccess = !info.openVideoShoudApprove
        reqParams.micAccess = info.openAudioShoudApprove
        reqParams.roomId = info.roomId
        reqParams.userId = info.userId
        HttpManager.requestUserPermissionsUpdate(reqParams) {
            self.dismissLoading()
            self.info.openAudioShoudApprove = !self.info.openAudioShoudApprove
            ARConferenceManager.getEntryParams().audioAccess = reqParams.micAccess
        } failure: { (error) in
            self.dismissLoading()
            self.showToast(error.localizedDescription)
            self.tableView.reloadData()
        }
    }
    
    func uploadLog() {
        guard uploading == false else {
            return
        }
        uploading = true
        tableView.reloadRows(at: [IndexPath(row: 0, section: 4)], with: .automatic)
        ARConferenceManager.getRteEngine().uploadSDKLogToAgoraService { [weak self](str) in
            self?.uploading = false
            self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 4)], with: .automatic)
            self?.showToast(NSLocalizedString("set_t21", comment: ""))
        } fail: { [weak self](error) in
            self?.uploading = false
            self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 4)], with: .automatic)
            self?.dismissLoading()
            if error.code == -1 {
                let msg = NSLocalizedString("set_t22", comment: "")
                self?.showToast(msg)
            }
            else {
                if let msg = error.message { self?.showToast(msg) }
            }
        }
    }
    
    func showAboutVC() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AboutVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SetVC: SelectedNotiTypeVCDelegate {
    
    func selectedNotiTypeVCdidTapSureButton(type: NotiType) {
        ARUserDefaults.setNotiTypeValue(type.rawValue)
        self.notiType = type
        tableView.reloadData()
        delegate?.setVcDidUpdateNotiType()
    }
}

extension SetVC: SetSwitchCellDelegate {
    
    func setSwitchCellSwitchValueDidChange(_ on: Bool, at indexPath: IndexPath) {
        if indexPath.section == 2, indexPath.row == 0 {
            setVideoAccess()
            return
        }
        
        if indexPath.section == 2, indexPath.row == 1 {
            setAudioAccess()
            return
        }
    }
    
}

extension SetVC {
    struct Info {
        let roomId: String
        let roomName: String
        var roomPsd: String
        var userName: String
        let userId: String
        let userRole: String
        let headImageName: String
        var openVideoShoudApprove: Bool
        var openAudioShoudApprove: Bool
        let beauty: Bool
        let ai: Bool
        let inOutNotiType: Int
        
        var isHost: Bool {
            return userRole == "host"
        }
        
        var roleName: String {
            return isHost ? NSLocalizedString("set_t3", comment: "") : NSLocalizedString("set_t15", comment: "")
        }
    }
    
    enum EditVCType {
        case psd
        case userName
    }
}
