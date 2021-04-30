//
//  Bundle+Extension.swift
//  AgoraSceneUI
//
//  Created by ZYP on 2021/1/13.
//

import Foundation

extension Bundle {
    func image(name: String) -> UIImage? {
        return UIImage(named: name, in: self, compatibleWith: nil)
    }
}
