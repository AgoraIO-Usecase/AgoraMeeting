//
//  LoginSetVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/17.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import AgoraRoom

class LoginSetVC: BaseViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)
    var info: Info!
    var uploadLogUserId: String!
    var uploading = false
    var uploadRte: AgoraRteEngine?
    var notiType = NotiType(rawValue: ARUserDefaults.getNotiTypeValue())!
    
    init(info: Info, uploadLogUserId: String) {
        self.info = info
        self.uploadLogUserId = uploadLogUserId
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
        
        let setImageCellNib = UINib(nibName: SetImageCell.idf(), bundle: nil)
        let setSwitchCellNib = UINib(nibName: SetSwitchCell.idf(), bundle: nil)
        let setCenterTextCellNib = UINib(nibName: SetCenterTextCell.idf(), bundle: nil)
        
        tableView.register(setImageCellNib, forCellReuseIdentifier: SetImageCell.idf())
        tableView.register(setSwitchCellNib, forCellReuseIdentifier: SetSwitchCell.idf())
        tableView.register(setCenterTextCellNib, forCellReuseIdentifier: SetCenterTextCell.idf())
        
        tableView.frame = view.bounds
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func showAboutVC() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AboutVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func uploadLog() {
        guard uploading == false else {
            return
        }
        uploading = true
        let idnexPaths = [IndexPath(row: 0, section: 3)]
        self.showLoading()
        self.tableView.reloadRows(at: idnexPaths, with: .automatic)
        
        var config = AgoraRteEngineConfig(appId: KeyCenter.agoraAppid(), customerId: KeyCenter.customerId(), customerCertificate: KeyCenter.customerCertificate(), userId: uploadLogUserId!)
        config.logFilePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                 .userDomainMask,
                                                                 true).first!.appending("/Logs")
        config.logConsolePrintType = .none
        config = ARConferenceManager.setDefaultHost(config)
        if let rte = uploadRte {
            rte.uploadSDKLogToAgoraService { [weak self](str) in
                self?.uploading = false
                self?.tableView.reloadRows(at: idnexPaths, with: .automatic)
                self?.dismissLoading()
                self?.showToast(NSLocalizedString("set_t21", comment: ""))
            } fail: { [weak self](error) in
                self?.uploading = false
                self?.tableView.reloadRows(at: idnexPaths, with: .automatic)
                self?.dismissLoading()
                if error.code == -1 {
                    let msg = NSLocalizedString("set_t22", comment: "")
                    self?.showToast(msg)
                }
                else {
                    if let msg = error.message { self?.showToast(msg) }
                }
            }
            return
        }
        
        /// rte not create
        AgoraRteEngine.create(with: config) { [weak self](rte) in
            self?.uploadRte = rte
            rte.uploadSDKLogToAgoraService { [weak self](str) in
                self?.uploading = false
                self?.tableView.reloadRows(at: idnexPaths, with: .automatic)
                self?.dismissLoading()
                self?.showToast(NSLocalizedString("set_t21", comment: ""))
            } fail: { [weak self](error) in
                self?.uploading = false
                self?.tableView.reloadRows(at: idnexPaths, with: .automatic)
                self?.dismissLoading()
                if error.code == -1 {
                    let msg = NSLocalizedString("set_t22", comment: "")
                    self?.showToast(msg)
                }
                else {
                    if let msg = error.message { self?.showToast(msg) }
                }
            }
        } fail: { [weak self](error) in
            self?.uploading = false
            self?.tableView.reloadRows(at: idnexPaths, with: .automatic)
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
    
    func showSelectedNotiTypeVC() {
        let vc = SelectedNotiTypeVC()
        vc.delegate = self
        vc.show(in: self, selected: NotiType(rawValue: ARUserDefaults.getNotiTypeValue())!)
    }
    

}

extension LoginSetVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 2 }
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        let textColor = UIColor(red: 0.254675, green: 0.302331, blue: 0.349586, alpha: 1)
        if section == 0, row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SetImageCell.idf(), for: indexPath) as! SetImageCell
            cell.tipText?.text = NSLocalizedString("set_t19", comment: "")
            cell.imgView?.image = UIImage(named: info.headImageName)
            return cell
        }
        if section == 0, row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = NSLocalizedString("set_t13", comment: "")
            cell.detailTextLabel?.text = info.userName
            cell.selectionStyle = .none
            cell.textLabel?.textColor = textColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
            return cell
        }
        if section == 1, row == 0 { /** 美颜 **/
            let cell = tableView.dequeueReusableCell(withIdentifier: SetSwitchCell.idf(), for: indexPath) as! SetSwitchCell
            cell.tipText?.text = NSLocalizedString("set_t20", comment: "")
            cell.switchBtn?.isEnabled = false
            cell.switchBtn?.isOn = false
            return cell
        }
        if section == 1, row == 1 { /** AI降噪 **/
            let cell = tableView.dequeueReusableCell(withIdentifier: SetSwitchCell.idf(), for: indexPath) as! SetSwitchCell
            cell.textLabel?.textColor = UIColor.text()
            cell.tipText?.text = NSLocalizedString("set_t23", comment: "")
            cell.switchBtn?.isOn = false
            cell.switchBtn?.isEnabled = false
            cell.selectionStyle = .none
            return cell
        }
        if section == 1, row == 2 {
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = NSLocalizedString("set_t4", comment: "")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor = textColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1, indexPath.row == 3  {
            showAboutVC()
        }
        
        if indexPath.section == 1, indexPath.row == 2 {
            showSelectedNotiTypeVC()
        }
    }
}

extension LoginSetVC: SelectedNotiTypeVCDelegate {
    func selectedNotiTypeVCdidTapSureButton(type: NotiType) {
        ARUserDefaults.setNotiTypeValue(type.rawValue)
        self.notiType = type
        tableView.reloadData()
    }
}

extension LoginSetVC {
    struct Info {
        let headImageName: String
        let userName: String
        let audioAccess: Bool
        let videoAccess: Bool
    }
}
