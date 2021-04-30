//
//  TextFieldCustomClear.swift
//  VideoConference
//
//  Created by ZYP on 2021/3/29.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit


class TextFieldCustomClear : UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let clearButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 15)))
        clearButton.setImage(UIImage(named: "close")!, for: .normal)

        rightView = clearButton
        clearButton.addTarget(self, action: #selector(clearClicked(button:)), for: .touchUpInside)

        clearButtonMode = .never
        rightViewMode = .whileEditing
    }
    
    @objc func clearClicked(button: UIButton) {
        text = ""
    }
}
