//
//  ASScoreView.swift
//  AgoraSceneUI
//
//  Created by ZYP on 2021/1/13.
//

import UIKit

class ASScoreStarView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    
    public var value = 5
    
    @IBAction func buttonTap(_ sender: UIButton) {
        
        if sender == button1 {
            button1.isSelected = true;
            button2.isSelected = false;
            button3.isSelected = false;
            button4.isSelected = false;
            button5.isSelected = false;
            value = 1
            detailLabel.text = "\(value)" + NSLocalizedString("score_t8", comment: "")
            return
        }
        if sender == button2 {
            button1.isSelected = true;
            button2.isSelected = true;
            button3.isSelected = false;
            button4.isSelected = false;
            button5.isSelected = false;
            value = 2
            detailLabel.text = "\(value)" + NSLocalizedString("score_t8", comment: "")
            return
        }
        if sender == button3 {
            button1.isSelected = true;
            button2.isSelected = true;
            button3.isSelected = true;
            button4.isSelected = false;
            button5.isSelected = false;
            value = 3
            detailLabel.text = "\(value)" + NSLocalizedString("score_t8", comment: "")
            return
        }
        if sender == button4 {
            button1.isSelected = true;
            button2.isSelected = true;
            button3.isSelected = true;
            button4.isSelected = true;
            button5.isSelected = false;
            value = 4
            detailLabel.text = "\(value)" + NSLocalizedString("score_t8", comment: "")
            return
        }
        if sender == button5 {
            button1.isSelected = true;
            button2.isSelected = true;
            button3.isSelected = true;
            button4.isSelected = true;
            button5.isSelected = true;
            value = 5
            detailLabel.text = "\(value)" + NSLocalizedString("score_t8", comment: "")
            return
        }
        
    }
    
}
