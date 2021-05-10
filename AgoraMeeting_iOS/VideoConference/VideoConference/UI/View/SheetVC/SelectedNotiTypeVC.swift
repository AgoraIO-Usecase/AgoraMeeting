//
//  SelectedNotiTypeVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/17.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit
import Presentr

protocol SelectedNotiTypeVCDelegate: NSObject {
    func selectedNotiTypeVCdidTapSureButton(type: NotiType)
}

class SelectedNotiTypeVC: UIViewController {
    
    weak var delegate: SelectedNotiTypeVCDelegate?
    let dataList: [NotiType] = [.never, .n10, .n20, .n30, .n40, .n50, .n60, .n70, .n80, .n90, .n100, .always]
    var defaultSelected: NotiType = .never
    private let contentView = Bundle.main.loadNibNamed("SelectedNotiTypeView", owner: nil, options: nil)?.first as! SelectedNotiTypeView
    private let presenter = Presentr(presentationType: .bottomHalf)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        contentView.pickerView.dataSource = self
        contentView.pickerView.delegate = self
        
        let bottomBgView = UIView()
        bottomBgView.backgroundColor = .white
        view.addSubview(bottomBgView)
        bottomBgView.translatesAutoresizingMaskIntoConstraints = false
        bottomBgView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomBgView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomBgView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomBgView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 398).isActive = true
        
        contentView.cancleButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        contentView.sureButton.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        
        contentView.pickerView.reloadComponent(0)
        contentView.pickerView.selectRow(defaultSelected.rawValue, inComponent: 0, animated: true)
    }
    
    public func show(in vc: UIViewController, selected: NotiType) {
        defaultSelected = selected
        presenter.backgroundTap = .dismiss
        vc.customPresentViewController(presenter, viewController: self, animated: true, completion: nil)
    }
    
    @objc func buttonTap(button: UIButton) {
        if button == contentView.cancleButton {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let index = contentView.pickerView.selectedRow(inComponent: 0)
        let selectedItem = dataList[index]
        delegate?.selectedNotiTypeVCdidTapSureButton(type: selectedItem)
        dismiss(animated: true, completion: nil)
    }
    
}

extension SelectedNotiTypeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataList[row].description
    }
}

