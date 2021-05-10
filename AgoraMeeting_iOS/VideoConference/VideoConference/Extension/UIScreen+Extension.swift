//
//  UIScreen+Extension.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/4.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

extension UIScreen {
    static var width: CGFloat = {
        return UIScreen.main.bounds.size.width
    }()
    
    static var height: CGFloat = {
        return UIScreen.main.bounds.size.height
    }()
    
}
