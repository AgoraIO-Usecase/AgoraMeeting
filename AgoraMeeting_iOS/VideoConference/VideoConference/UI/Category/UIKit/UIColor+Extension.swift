//
//  UIColor+Extension.swift
//  AgoraSceneUI
//
//  Created by ZYP on 2021/1/13.
//

import Foundation
extension UIColor {
    var rgbComponents: [CGFloat] {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return [r, g, b, a]
    }
    
}


