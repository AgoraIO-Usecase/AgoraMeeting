//
//  MessageVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/23.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import LXFProtocolTool

protocol MessageVCDelegate: NSObject {
    func messageVcDidUpdateNotiType()
    func shouldShowSetVC()
}

class MessageVC: BaseViewController {
    typealias Info = MessageVM.Info
    private let messageView = MessageView()
    private var msgInfos = [Info]()
    private var notiInfos = [NotiCell.Info]()
    private let msgvm = MessageVM()
    private let notiVM = NotiVM()
    private var isAutoScrollToBottomNoti = false
    weak var delegate: MessageVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func setup() {
        title = NSLocalizedString("msg_t4", comment: "")
        messageView.frame = view.bounds
        view.addSubview(messageView)
    }
    
    func commonInit() {
        messageView.tableView1.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        messageView.tableView1.register(UINib(nibName: "MessageSelfCell", bundle: nil), forCellReuseIdentifier: "MessageSelfCell")
        messageView.tableView1.delegate = self
        messageView.tableView1.dataSource = self
        messageView.tableView1.estimatedRowHeight = 100
        messageView.tableView1.rowHeight = UITableView.automaticDimension
        messageView.tableView1.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        messageView.tableView2.register(NotiCell.self, forCellReuseIdentifier: "NotiCell")
        messageView.tableView2.delegate = self
        messageView.tableView2.dataSource = self
        messageView.tableView2.estimatedRowHeight = 100
        messageView.tableView2.rowHeight = UITableView.automaticDimension
        messageView.tableView2.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        messageView.delegate = self
        msgvm.delegate = self
        msgvm.start()
        scrollToBottomMsg()
        
        notiVM.delegate = self
        notiVM.start()
        MessageCollector.default.cleanUnReadCount()
        emptyInit()
        
    }
    
    func scrollToBottomMsg() {
        if msgInfos.count > 0 {
            let idnexPath = IndexPath(row: msgInfos.count - 1, section: 0)
            messageView.tableView1.scrollToRow(at: idnexPath, at: .top, animated: true)
        }
    }
    
    func scrollToBottomNoti() {
        if notiInfos.count > 0 {
            let idnexPath = IndexPath(row: notiInfos.count - 1, section: 0)
            messageView.tableView2.scrollToRow(at: idnexPath, at: .top, animated: true)
        }
    }
    
    func updateUserInfo(userInfos: [MeetingVM.Info]) {
        msgvm.updateUserInfo(userInfos: userInfos)
    }
    
    func showSelectedNotiTypeVC() {
        delegate?.shouldShowSetVC()
    }
    
}

extension MessageVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == messageView.tableView1 ? msgInfos.count : notiInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == messageView.tableView1 {
            let info = msgInfos[indexPath.row]
            if info.isSelfSend {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageSelfCell", for: indexPath) as! MessageSelfCell
                cell.update(withTime: Int(info.timestamp), message: info.message)
                cell.update(MessageSelfCellStatus(rawValue: info.status.rawValue)!)
                cell.updateTimeShow(info.showTime)
                cell.indexPath = indexPath
                cell.delegate = self
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
                cell.update(withTime: Int(info.timestamp), message: info.message, username: info.userName)
                cell.updateTimeShow(info.showTime)
                return cell
            }
        }
        
        /// for tableView2
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotiCell", for: indexPath) as! NotiCell
        let info = notiInfos[indexPath.row]
        cell.setInfo(info: info)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == messageView.tableView1 { return UITableView.automaticDimension }
        let info = notiInfos[indexPath.row]
        return info.cellHeight
    }
    
}

extension MessageVC: MessageViewDelegate {
    func messageViewDidTapSend(text: String) {
        msgvm.send(text: text)
    }
    
    func messageViewShouldTableViewScrollToBottom() {
        scrollToBottomMsg()
    }
}

extension MessageVC: MessageVMDelegate {
    func messageVMShouldUpdateInfos(infos: [MessageVM.Info]) {
        if infos.count == 0 { showMsgEmpty() }
        self.msgInfos = infos
        messageView.tableView1.reloadData()
        scrollToBottomMsg()
    }
    
    func messageVMShouldTips(text: String) {
        showToast(text)
    }
}

extension MessageVC: MessageSelfCellDelegate {
    func messageSelfCelldidTapFailButton(_ indexPath: IndexPath) {
        let info = msgInfos[indexPath.row]
        msgvm.retry(info: info)
    }
}

extension MessageVC: NotiVMDelegate {
    func notiVMShouldShowNotiSheetVC() {
        showSelectedNotiTypeVC()
    }
    
    func notiVMShouldUpdateInfos(infos: [NotiCell.Info], reloadAll: Bool) {
        if infos.count == 0 { showMNotiEmpty() }
        notiInfos = infos
        messageView.tableView2.reloadData()
        
        if isAutoScrollToBottomNoti == false {
            isAutoScrollToBottomNoti = true
            scrollToBottomNoti()
        }
    }
    
    func notiVMShouldShowLoading() {
        showLoading()
    }
    
    func notiVMShouldDismissLoading() {
        dismissLoading()
    }
    
    func notiVMDidErrorWithTips(tips: String) {
        showToast(tips)
    }
}

extension MessageVC: NotiCellDelegate {
    func notiCellDidTapButton(info: NotiCell.Info) {
        notiVM.handleInfo(info: info)
    }
}

extension MessageVC: EmptyDataSetable {
    func emptyInit() {
        lxf.emptyViewWillAppear(messageView.tableView1) {[weak self] in
            self?.messageView.tableView1.contentOffset = CGPoint.zero
        }
        lxf.emptyViewWillAppear(messageView.tableView2) {[weak self] in
            self?.messageView.tableView2.contentOffset = CGPoint.zero
        }
    }
    
    func showMsgEmpty() {
        var conf = EmptyDataSetConfigure.init()
        conf.tipStr = NSLocalizedString("msg_t2", comment: "")
        conf.verticalOffset = -100
        lxf.updateEmptyDataSet(messageView.tableView1, config: conf)
    }
    
    func showMNotiEmpty() {
        var conf = EmptyDataSetConfigure.init()
        conf.tipStr = NSLocalizedString("msg_t3", comment: "")
        conf.verticalOffset = -100
        lxf.updateEmptyDataSet(messageView.tableView2, config: conf)
    }
}

extension MessageVC: SelectedNotiTypeVCDelegate {
    func selectedNotiTypeVCdidTapSureButton(type: NotiType) {
        ARUserDefaults.setNotiTypeValue(type.rawValue)
        delegate?.messageVcDidUpdateNotiType()
    }
}



