//
//  LoginTipsView.swift
//  VideoConference
//
//  Created by ZYP on 2021/4/26.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

class LoginTipsView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let baView = UIImageView(image: UIImage(named: "tipBg"))
        let label1 = UILabel()
        let label2 = UILabel()
        let label3 = UILabel()
        
        label1.numberOfLines = 0
        label1.font = UIFont.systemFont(ofSize: 12)
        label1.textColor = UIColor(hex: 0xAAAFB5)
        label1.text = NSLocalizedString("login_t10", comment: "")
        
        label2.numberOfLines = 0
        label2.font = UIFont.systemFont(ofSize: 12)
        label2.textColor = UIColor(hex: 0xAAAFB5)
        label2.text = NSLocalizedString("login_t11", comment: "")
        
        label3.numberOfLines = 0
        label3.font = UIFont.systemFont(ofSize: 12)
        label3.textColor = UIColor(hex: 0xAAAFB5)
        label3.text = NSLocalizedString("login_t12", comment: "")
        
        addSubview(baView)
        addSubview(label1)
        addSubview(label2)
        addSubview(label3)
        
        baView.translatesAutoresizingMaskIntoConstraints = false
        label1.translatesAutoresizingMaskIntoConstraints = false
        label2.translatesAutoresizingMaskIntoConstraints = false
        label3.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([baView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     baView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     baView.topAnchor.constraint(equalTo: topAnchor),
                                     baView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        NSLayoutConstraint.activate([label1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                                     label1.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                                     label1.topAnchor.constraint(equalTo: topAnchor, constant: 15)])
        
        NSLayoutConstraint.activate([label2.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                                     label2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                                     label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 8)])
        
        NSLayoutConstraint.activate([label3.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                                     label3.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                                     label3.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 8)])
    }

}
