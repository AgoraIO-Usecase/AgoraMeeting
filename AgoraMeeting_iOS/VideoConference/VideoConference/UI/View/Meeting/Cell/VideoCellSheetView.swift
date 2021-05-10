//
//  VideoCellSheetView.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/2.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

protocol VideoCellSheetViewDelegate: NSObject {
    func videoCellSheetViewShouldUpdateHeight(height: CGFloat)
    func buttonDidTap(info: VideoCellSheetView.Info)
}

class VideoCellSheetView: UIView {
    private var buttons = [UIButton]()
    private var lines = [UIView]()
    private var infos = [Info]()
    weak var delegate: VideoCellSheetViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.75)
        layer.cornerRadius = 8
    }
    
    func setInfos(infos: [Info]) {
        for btn in buttons {
            btn.removeTarget(self, action: nil, for: .touchUpInside)
            btn.removeFromSuperview()
        }
        for line in lines {
            line.removeFromSuperview()
        }
        self.infos = infos
        let count = CGFloat(infos.count)
        for i in 0..<infos.count {
            let info = infos[i]
            addButton(index: i, info: info)
            if i < Int(count) - 1 { addLine(index: i) }
        }
        
        let height: CGFloat = count * 44.0 + count
        delegate?.videoCellSheetViewShouldUpdateHeight(height: height)
        layoutIfNeeded()
    }
    
    private func addButton(index: Int, info: Info) {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitle(info.title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.tag = index
        btn.addTarget(self, action: #selector(buttonTap(button:)), for: .touchUpInside)
        
        addSubview(btn)
        buttons.append(btn)
        let y: CGFloat = CGFloat(index) * 44.0 + CGFloat(index) * 1.0
        btn.frame = CGRect(x: 0, y: y, width: 141, height: 44)
    }
    
    private func addLine(index: Int) {
        let line = UIView()
        line.backgroundColor = UIColor(hex: 0x3D3D3D)
        addSubview(line)
        lines.append(line)
        let y: CGFloat = CGFloat(index) * 44.0 + CGFloat(index) * 1.0 + 44.0
        line.frame = CGRect(x: 0, y: y, width: frame.size.width, height: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonTap(button: UIButton) {
        let info = infos[button.tag]
        delegate?.buttonDidTap(info: info)
    }
}

extension VideoCellSheetView {
    struct Info: Equatable {
        let actionType: ActionType
        
        enum ActionType {
            case closeAudio
            case closeVideo
            case setAsHost
            case abandonHost
            case becomeHost
            case remove
        }
        
        var title: String {
            switch actionType {
            case .closeAudio:
                return NSLocalizedString("mem_t13", comment: "")
            case .closeVideo:
                return NSLocalizedString("mem_t2", comment: "")
            case .setAsHost:
                return NSLocalizedString("mem_t12", comment: "")
            case .abandonHost:
                return NSLocalizedString("mem_t8", comment: "")
            case .becomeHost:
                return NSLocalizedString("meeting_t25", comment: "")
            case .remove:
                return NSLocalizedString("mem_t11", comment: "")
            }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.actionType == rhs.actionType
        }
    }
}
