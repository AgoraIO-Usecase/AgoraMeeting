//
//  MemberVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/18.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import AgoraRoom
import DZNEmptyDataSet
import LXFProtocolTool

class MemberVC: BaseViewController {
    
    typealias Info = MemberVM.Info
    let tableView = UITableView(frame: .zero, style: .plain)
    var dataList = [Info]()
    var style = NavStyle.normal
    let searchBar = UISearchBar()
    var rightButtonSearch: UIBarButtonItem!
    var rightButtonCancle: UIBarButtonItem!
    let titleLabel = UILabel()
    var vm: MemberVM!
    var delegate: MemberVCDelegate?
    
    init(infos: [Info]) {
        vm = MemberVM(infos: infos)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        
    }
    
    func setup() {
        vm.delegate = self
        
        rightButtonSearch = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.barButtonTap(btn:)))
        rightButtonCancle = UIBarButtonItem(title: NSLocalizedString("mem_t3", comment: ""), style: .plain, target: self, action: #selector(self.barButtonTap(btn:)))
        rightButtonCancle.tintColor = UIColor(hex: 0x4DA1FF)
        searchBar.setApperance()
        searchBar.placeholder = NSLocalizedString("mem_t7", comment: "")
        searchBar.delegate = self
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: UserCell.idf, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: UserCell.idf)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(hex: 0xF8F9FB)
        setStyle(style: .normal)
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    func commonInit() {
        vm.start()
        emptyInit()
    }
    
    
    func setStyle(style: NavStyle) {
        self.style = style
        if style == .normal {
            titleLabel.text = NSLocalizedString("mem_t1", comment: "") + "(\(dataList.count))"
            titleLabel.frame = CGRect(x: UIScreen.width/2 - 150, y: 0, width: 300, height: 20)
            titleLabel.textAlignment = .center
            navigationItem.titleView = titleLabel
            navigationItem.setHidesBackButton(false, animated: false)
            navigationItem.rightBarButtonItem = rightButtonSearch
        }
        else {
            searchBar.alpha = 0
            navigationItem.titleView = searchBar
            navigationItem.titleView?.layoutIfNeeded()
            UIView.animate(withDuration: 0.35) {
                self.searchBar.alpha = 1
                self.navigationItem.titleView?.layoutIfNeeded()
            }
            navigationItem.setHidesBackButton(true, animated: true)
            navigationItem.rightBarButtonItem = rightButtonCancle
        }
    }
    
    @objc func barButtonTap(btn: UIBarButtonItem) {
        setStyle(style: btn == rightButtonSearch ? .search : .normal)
        
        if btn == rightButtonCancle {
            vm.setNormalDisplay()
        }
    }
    
    func showActionSheet(info: Info) {

        guard let currentUser = vm.currentUserInfo else {
            return
        }
        
        let vc = MemberSheetVC()
        vc.set(title: info.uiInfo.title, image: UIImage(named: info.uiInfo.headImageName)!)
        
        if info.isMe {
            var a3Title = ""
            if info.uiInfo.isHost {
                a3Title = NSLocalizedString("mem_t8", comment: "")
            }
            else {
                let hasHost = dataList.filter({ $0.uiInfo.isHost }).count > 0
                a3Title = hasHost ? "" : NSLocalizedString("meeting_t25", comment: "")
            }
            let a3 = MemberSheetVC.Action(title: a3Title, style: .default, handler: {
                info.uiInfo.isHost ? self.vm.abandonHost() : self.vm.beHost()
            })
            let a5 = MemberSheetVC.Action(title: NSLocalizedString("mem_t3", comment: ""), style: .cancel, handler: nil)
            a3Title != "" ? vc.addAction(a3) : nil
            vc.addAction(a5)
            if vc.actions.count == 1 { return }
            vc.show(in: self)
        }
        else {
            if !currentUser.uiInfo.isHost { return }
            let a1 = MemberSheetVC.Action(title: NSLocalizedString("mem_t13", comment: ""), style: .default, handler: {
                self.vm.closeRemoteVideoAudio(isVideo: false, info: info)
            })
            let a2 = MemberSheetVC.Action(title: NSLocalizedString("mem_t2", comment: ""), style: .default, handler: {
                self.vm.closeRemoteVideoAudio(isVideo: true, info: info)
            })
            let a3 = MemberSheetVC.Action(title: NSLocalizedString("mem_t12", comment: ""), style: .default, handler: {
                self.vm.setHost(info: info)
            })
            let a4 = MemberSheetVC.Action(title: NSLocalizedString("mem_t11", comment: ""), style: .default, handler: {
                self.vm.kickOut(currentUserInfo: currentUser, info: info)
            })
            let a5 = MemberSheetVC.Action(title: NSLocalizedString("mem_t3", comment: ""), style: .cancel, handler: nil)
            if info.uiInfo.audioEnable { vc.addAction(a1) }
            if info.uiInfo.videoEnable { vc.addAction(a2) }
            if currentUser.uiInfo.isHost, !info.uiInfo.isHost { vc.addAction(a3) }
            vc.addAction(a4)
            vc.addAction(a5)
            vc.show(in: self)
        }
    }
    
    func updateInfos(infos: [Info]) {
        vm.updateInfos(infos: infos, mode: style == .normal ? .normal : .searching, searchText: searchBar.text ?? "")
    }
    
    func showRequestMicAlert() {
        let vc = UIAlertController(title: nil, message: NSLocalizedString("meeting_t16", comment: ""), preferredStyle: .alert)
        let a1 = UIAlertAction(title: NSLocalizedString("mem_t10", comment: ""), style: .default, handler: { [unowned self](_) in
            self.vm.requestAudioOpen(audioOpenSHouldApply: true)
        })
        let a2 = UIAlertAction(title: NSLocalizedString("mem_t3", comment: ""), style: .default, handler: nil)
        vc.addAction(a2)
        vc.addAction(a1)
        present(vc, animated: true, completion: nil)
    }
    
    func showRequestCameraAlert() {
        let vc = UIAlertController(title: nil, message: NSLocalizedString("meeting_t15", comment: ""), preferredStyle: .alert)
        let a1 = UIAlertAction(title: NSLocalizedString("mem_t10", comment: ""), style: .default, handler: {  [unowned self](_) in
            self.vm.requestVideoOpen(audioOpenSHouldApply: true)
        })
        let a2 = UIAlertAction(title: NSLocalizedString("mem_t3", comment: ""), style: .default, handler: nil)
        vc.addAction(a2)
        vc.addAction(a1)
        present(vc, animated: true, completion: nil)
    }
    
}

extension MemberVC: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.idf, for: indexPath) as! UserCell
        let info = dataList[indexPath.row]
        cell.setInfo(info: info.uiInfo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let info = dataList[indexPath.row]
        showActionSheet(info: info)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
}

extension MemberVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        vm.search(text: searchBar.text ?? "")
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        vm.search(text: searchBar.text ?? "")
    }
}

extension MemberVC: MemberVMDelegate {
    
    func memberVMShouldShowVideoAlert() {
        showRequestCameraAlert()
    }
    
    func memberVMShouldShowAudioAlert() {
        showRequestMicAlert()
    }
    
    func memberVMDidRequestHostError(error: NSError) {
        delegate?.memberVCDidRequestHostError(error: error)
    }
    
    func memberVMDidRequestVideoOpen() {
        delegate?.memberVCShouldStartVideoTimer()
    }
    
    func memberVMDidRequestAudioOpen() {
        delegate?.memberVCShouldStartAudioTimer()
    }
    
    func memberVMShouldDismissLoading() {
        dismissLoading()
    }
    
    func memberVMShouldShowToast(text: String) {
        dismissLoading()
        showToast(text)
    }
    
    func memberVMShouldShowLoading() {
        showLoading()
    }
    
    func memberVMDidUpdateInfos(infos: [MemberVM.Info]) {
        if infos.count == 0 { showEmpty() }
        self.dataList = infos
        titleLabel.text = NSLocalizedString("mem_t1", comment: "") + "(\(dataList.count))"
        tableView.reloadData()
    }
}

extension MemberVC: EmptyDataSetable {
    func emptyInit() {
        lxf.emptyViewWillAppear(tableView) {[weak self] in
            self?.tableView.contentOffset = CGPoint.zero
        }
    }
    
    func showEmpty() {
        var conf = EmptyDataSetConfigure.init()
        conf.tipStr = NSLocalizedString("mem_t14", comment: "")
        conf.verticalOffset = -100
        lxf.updateEmptyDataSet(tableView, config: conf)
    }
}

extension MemberVC {
    enum NavStyle {
        case normal
        case search
    }
}

extension MeetingVM.Info {
    var toUserCellInfo: UserCell.Info {
        let headImageName = String.headImageName(userName: user.userName.md5())
        var title = user.userName
        if isHost, user.userId == ARConferenceManager.getLocalUser().info.userId {
            title +=  NSLocalizedString("mem_t15", comment: "")
        }
        else if isHost {
            title += NSLocalizedString("mem_t16", comment: "")
        }
        else if isMe {
            title += NSLocalizedString("mem_t17", comment: "")
        }
        let name = user.userName
        return UserCell.Info(headImageName: headImageName,
                             title: title,
                             name: name,
                             userId: user.userId,
                             isHost: isHost,
                             isShare: isShare,
                             videoEnable: hasVideo,
                             audioEnable: hasAudio)
    }
}
extension UISearchBar {
    fileprivate func setApperance() {
        if let searchField = value(forKey: "searchField") as? UITextField {
            searchField.layer.borderWidth = 1.0
            searchField.layer.borderColor = UIColor(hex: 0x4DA1FF).cgColor
            searchField.layer.cornerRadius = 7
            searchField.layer.masksToBounds = true
            searchField.font = UIFont.systemFont(ofSize: 13)
            searchField.textColor = UIColor(hex: 0x333333)
            searchField.tintColor = UIColor(hex: 0x4DA1FF)
        }
    }
}


