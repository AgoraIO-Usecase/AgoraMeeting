//
//  BaseVC.swift
//  VideoConference
//
//  Created by ZYP on 2021/2/4.
//  Copyright © 2021 agora. All rights reserved.
//

import UIKit

open class BaseVC: UIViewController {
    
    let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF8F9FB)
        
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
        activityIndicatorView.color = .gray
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func showToast(text: String) {
        let tvc = self.topVC
        if tvc != nil {
            DispatchQueue.main.async {
                tvc?.view.makeToast(text)
            }
        }
    }
    
    func showToastTop(text: String) {
        let tvc = self.topVC
        if tvc != nil {
            DispatchQueue.main.async {
                tvc?.view.makeToast(text, duration: 0.1, position: CSToastPositionTop)
            }
        }
    }

}

extension BaseVC {
    var topVC: UIViewController? {
        get {
            let window = UIApplication.shared.windows.first
            let nvc = window?.rootViewController as? UINavigationController
            if nvc != nil {
                return nvc?.visibleViewController
            }
            return nil
        }
    }
}
