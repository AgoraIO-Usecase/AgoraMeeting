//
//  EEWhiteboardTool.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/28.
//  Copyright © 2021 agora. All rights reserved.
//

import Foundation

protocol EEWhiteboardToolDelegate: NSObject {
    func eeWhiteboardToolDidTapButton(action: EEWhiteboardToolView.ActionType)
    func eeWhiteboardToolDidTapButtonClean()
}

class EEWhiteboardToolView: UIView {
    weak var delegate: EEWhiteboardToolDelegate?
     
    enum ActionType: Int {
        case select = 1
        case rantangle = 6
        case ellipse = 7
        case pan = 2
        case text = 3
        case eraser = 4
        case color = 5
        
    }
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var cleanButton: UIButton!
    
    @IBAction func ButtonTap(_ sender: UIButton) {
        button1.isSelected = sender == button1
        button2.isSelected = sender == button2
        button3.isSelected = sender == button3
        button4.isSelected = sender == button4
        button5.isSelected = sender == button5
        button6.isSelected = sender == button6
        
        delegate?.eeWhiteboardToolDidTapButton(action: ActionType(rawValue: sender.tag)!)
    }
    
    @IBAction func cleanButtonTap(_ sender: UIButton) {
        delegate?.eeWhiteboardToolDidTapButtonClean()
    }
    
}
