//
//  TestNotiCellVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/4/12.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

class TestNotiCellVC: BaseViewController {
    let tableView = UITableView(frame: .zero, style: .plain)
    private var notiInfos = [NotiCell.Info]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        commonInit()
    }
    
    func setup() {
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        let infos1 = ["我是啊傻傻的按时大啥收到货爱仕达按时傻傻的按时大啥收到货爱仕达按时",
                      "货爱仕达按时-成为主持人",
                      "货爱仕达按时-成为主持人我是啊傻傻的按时大啥收到货爱仕达按时傻傻的按时大啥收到货爱仕达按时我是啊傻傻的按时大啥收到货爱仕达按时傻"]
            .map({ name -> NotiCell.Info in
                var info = NotiCell.Info(msg: name, time: "12:12 pm", typeValue: 0, timeStamp: Date().timeIntervalSince1970)
                info.isFirstCell = true
                info.showTime = false
                return info
            })
        let infos2 = ["我是啊傻傻的按时大啥收到货爱仕达按时傻傻的按时大啥收到货爱仕达按时",
                      "货爱仕达按时-成为主持人",
                      "货爱仕达按时-成为主持人我是啊傻傻的按时大啥收到货爱仕达按时傻傻的按时大啥收到货爱仕达按时我是啊傻傻的按时大啥收到货爱仕达按时傻"]
            .map({ name -> NotiCell.Info in
                var info = NotiCell.Info(msg: name, buttonTitle: "允许", buttonEnable: true, time: "12:12 pm", typeValue: 0, timeStamp: Date().timeIntervalSince1970 + 30)
                info.showTime = true
                return info
            })
        
        let infos3 = ["我是啊傻傻的按时大啥收到货爱仕达按时傻傻的按时大啥收到货爱仕达按时",
                      "货爱仕达按时-成为主持人",
                      "货爱仕达按时-成为主持人我是啊傻傻的按时大啥收到货爱仕达按时傻傻的按时大啥收到货爱仕达按时我是啊傻傻的按时大啥收到货爱仕达按时傻"]
            .map({ name -> NotiCell.Info in
                var info = NotiCell.Info(msg: name, buttonTitle: "允许", buttonEnable: true, timeCount: 20, time: "12:12 pm", typeValue: 0, targetUserId: name, timeStamp: Date().timeIntervalSince1970)
                info.showTime = false
                return info
            })
        
        notiInfos += infos1
        notiInfos += infos2
        notiInfos += infos3
        
    }
    
    func commonInit() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotiCell.self, forCellReuseIdentifier: "NotiCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor(hex: 0xEDEEEF)
        tableView.reloadData()
    }
}

extension TestNotiCellVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notiInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotiCell", for: indexPath) as! NotiCell
        let info = notiInfos[indexPath.row]
        cell.setInfo(info: info)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let info = notiInfos[indexPath.row]
        return info.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
