//
//  WhiteBoardVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/26.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation
import WhiteModule
import Whiteboard
class WhiteBoardVC: BaseViewController {
    typealias Info = WhiteBoardVM.Info
    let whiteBoardView = WhiteManager.createWhiteBoardView()
    var vm: WhiteBoardVM!
    let leftView = Bundle.main.loadNibNamed("EEWhiteboardToolView", owner: nil, options: nil)!.first! as! EEWhiteboardToolView
    let colorView = Bundle.main.loadNibNamed("EEColorShowView", owner: nil, options: nil)!.first! as! EEColorShowView
    
    init(info: Info) {
        super.init(nibName: nil, bundle: nil)
        self.vm = WhiteBoardVM(info: info)
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
    
    func setup() {
        title = NSLocalizedString("wb_t3", comment: "")
        whiteBoardView.frame = view.bounds
        whiteBoardView.isHidden = false
        whiteBoardView.backgroundColor = .white
        leftView.frame = CGRect(x: 10, y: 300, width: 46, height: 318)
        colorView.frame = CGRect(x: 70, y: 500, width: 180, height: 120)
        colorView.isHidden = true
        view.addSubview(whiteBoardView)
        view.addSubview(leftView)
        view.addSubview(colorView)
    }
    
    func commonInit() {
        leftView.delegate = self
        colorView.delegate = self
        vm.delegate = self
        vm.start(whiteBoardView: whiteBoardView)
    }
    
    @objc func closeBoardAction() {
        vm.closeWhiteBoard()
    }
    
    @objc func requestInteractAction() {
        vm.requestInteract()
    }
    
    @objc func abandonInteractAction() {
        vm.abandonInteract()
    }
    
    public func shouldEndWhiteBoard() {
        navigationController?.popViewController(animated: true)
    }
}

extension WhiteBoardVC: WhiteBoardVMDelegate {
    func whiteBoardVMShouldShowLoading() {
        showLoading()
    }
    
    func whiteBoardVMShouldDismissLoading() {
        dismissLoading()
    }
    
    func whiteBoardVMDidErrorWithTips(tips: String) {
        showToast(tips)
    }
    
    func whiteBoardVMDidCloseBoard() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func whiteBoardVMDidUpdateInfo(info: WhiteBoardVM.Info) {
        switch info.role {
        case .owner:
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("wb_t4", comment: ""),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(closeBoardAction))
            navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: 0xFF5F51)
            leftView.isHidden = false
            break
        case .audience:
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("wb_t1", comment: ""),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(requestInteractAction))
            navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: 0x4DA1FF)
            leftView.isHidden = true
            break
        case .interactor:
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("wb_t2", comment: ""),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(abandonInteractAction))
            navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: 0x4DA1FF)
            leftView.isHidden = false
            break
        }
    }
}


extension WhiteBoardVC: EEWhiteboardToolDelegate, EEColorShowViewDelegate {
    func eeColorShowViewDidSelecteColor(_ colorString: String) {
        let params = UIColor.convert(toRGB: UIColor(hexString: colorString)) as! [NSNumber]
        vm.setStrokeColor(color: params)
    }
    
    func eeWhiteboardToolDidTapButton(action: EEWhiteboardToolView.ActionType) {
        switch action {
        case .color:
            colorView.isHidden = !colorView.isHidden
            break
        case .select:
            vm.setApplianceAction(action: .select)
            break
        case .pan:
            vm.setApplianceAction(action: .pan)
            break
        case .text:
            vm.setApplianceAction(action: .text)
            break
        case .eraser:
            vm.setApplianceAction(action: .eraser)
            break
        case .rantangle:
            vm.setApplianceAction(action: .rectangle)
            break
        case .ellipse:
            vm.setApplianceAction(action: .ellipse)
            break
        }
    }
    
    func eeWhiteboardToolDidTapButtonClean() {
        if let wb = whiteBoardView as? WhiteBoardView {
            wb.room?.cleanScene(false)
        }
    }
}


